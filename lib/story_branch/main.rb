# frozen_string_literal: true

require_relative './pivotal_utils'
require_relative './git_utils'
require_relative './config_manager'
require 'tty-prompt'

module StoryBranch
  # Main story branch class. It is resposnible for the main interaction between
  # the user and Pivotal Tracker. It is also responsible for config init.
  class Main
    attr_accessor :tracker

    def initialize
      # TODO:
      # Config manager should be responsible for handling the configuration
      # and the story branch should only initialize one config manager that
      # has attr accessors for needed values
      # Read local config and decide what Utility to use
      # (e.g. PivotalUtils, GithubUtils, ...)
      @local_config = ConfigManager.init_config('.')
      @global_config = ConfigManager.init_config(Dir.home)
      @tracker = PivotalUtils.new(@local_config, @global_config)
      exit unless @tracker.valid?
    end

    def create_story_branch
      stories = @tracker.get_stories('started')
      if stories.empty?
        prompt.say 'No stories started, exiting'
        return
      end
      options = build_stories_structure(stories)
      story = prompt.select('Choose the feature you want to work on:',
                            options,
                            filter: true)
      create_feature_branch story
    end

    def story_finish
      current_story = GitUtils.current_branch_story_parts
      unless !current_story.empty? && @tracker.get_story_by_id(current_story[:id])
        prompt.error('No tracked feature associated with this branch')
        return
      end

      if GitUtils.status?(:untracked) || GitUtils.status?(:modified)
        message = <<~MESSAGE
          There are unstaged changes
          Use git add to stage changes before running git finish
          Use git stash if you want to hide changes for this commit
        MESSAGE
        prompt.say message
        return
      end

      unless GitUtils.status?(:added) || GitUtils.status?(:staged)
        message = <<~MESSAGE
          There are no staged changes.
          Nothing to do.
        MESSAGE
        prompt.say message
        return
      end

      commit_message = "[#{finish_tag} ##{current_story[:id]}] #{current_story[:title]}"
      abort_commit = prompt.no?('Commit with standard message?') do |q|
        q.suffix commit_message
      end
      if abort_commit
        prompt.say 'Aborted'
      else
        GitUtils.commit commit_message
      end
    end

    def story_start
      update_status('unstarted', 'started', 'start')
    end

    def story_unstart
      update_status('started', 'unstarted', 'unstart')
    end

    private

    def update_status(current_status, next_status, action)
      stories = @tracker.get_stories(current_status)
      if stories.empty?
        prompt.say "No #{current_status} stories, exiting"
        return
      end
      options = build_stories_structure(stories)
      story = prompt.select("Choose the feature you want to #{action}:", options, filter: true)
      return unless story
      res = story.update_state(next_status)
      if res.error&.present?
        prompt.error(res.error)
        return
      end
      prompt.ok("#{story.id} #{next_status}")
    end

    def build_stories_structure(stories)
      options = {}
      stories.each do |s|
        options[s.to_s] = s
      end
      options
    end

    def prompt
      return @prompt if @prompt
      @prompt = TTY::Prompt.new(interrupt: :exit)
    end

    def finish_tag
      return @finish_tag if @finish_tag
      fallback = @global_config.fetch(project_id,
                                      :finish_tag,
                                      default: 'Finishes')
      @finish_tag = @local_config.fetch(:finish_tag, default: fallback)
      @finish_tag
    end

    # TODO: cleanup as it is the same method as the one used in pivotal utils
    def project_id
      return @project_id if @project_id
      @project_id = @local_config.fetch(:project_id)
      @project_id
    end

    def create_feature_branch(story)
      return if story.nil?
      current_branch = GitUtils.current_branch
      prompt.say "You are checked out at: #{current_branch}"
      branch_name = prompt.ask('Provide a new branch name',
                               default: story.dashed_title)
      feature_branch_name = branch_name.chomp
      return unless validate_branch_name(feature_branch_name, story.id)
      feature_branch_name_with_story_id = "#{feature_branch_name}-#{story.id}"
      prompt.say("Creating: #{feature_branch_name_with_story_id} with #{current_branch} as parent")
      GitUtils.create_branch feature_branch_name_with_story_id
    end

    # Branch name validation
    def validate_branch_name(name, id)
      if GitUtils.branch_for_story_exists? id
        prompt.error("An existing branch has the same story id: #{id}")
        return false
      end
      if GitUtils.existing_branch? name
        prompt.error('This name is very similar to an existing branch. Avoid confusion and use a more unique name.')
        return false
      end
      true
    end
  end
end

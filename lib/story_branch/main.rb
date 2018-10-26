# frozen_string_literal: true

require_relative './pivotal_utils'
require_relative './config_manager'
require 'tty-prompt'

module StoryBranch
  # Main story branch class. It is resposnible for the main interaction between
  # the user and Pivotal Tracker. It is also responsible for config init.
  class Main
    attr_accessor :tracker

    def initialize
      # TODO: Read local config and decide what Utility to use
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
      options = {}
      stories.each do |s|
        options[s.to_s] = s
      end
      story = prompt.select('Choose the feature you want to work on:',
                            options,
                            filter: true)
      create_feature_branch story
    end

    def story_finish
      current_story = StoryBranch::GitUtils.current_branch_story_parts
      unless current_story && @tracker.story(current_story)
        prompt.error('No tracked feature associated with this branch')
        return
      end

      if GitUtils.status?(:untracked) || GitUtils.status?(:modified)
        prompt.say 'There are unstaged changes'
        prompt.say 'Use git add to stage changes before running git finish'
        prompt.say 'Use git stash if you want to hide changes for this commit'
        return
      end

      unless GitUtils.status?(:added) || GitUtils.status?(:staged)
        prompt.say 'There are no staged changes.'
        prompt.say 'Nothing to do'
        return
      end

      commit_message = "[#{@finish_tag} ##{current_story.id} #{@current_story.title}"
      prompt.say(commit_message)
      abort_commit = prompt.no?('Use standard finishing commit message?')
      if abort_commit
        prompt.say 'Aborted'
      else
        GitUtils.commit commit_message
      end
    end

    # TODO: Refactor story start and unstart due to similarities
    def story_start
      stories = @tracker.get_stories('unstarted')
      options = {}
      stories.each do |s|
        options[s.to_s] = s
      end
      story = prompt.select('Choose the feature you want to start:', options, filter: true)
      return unless story
      res = story.update_state('started')
      prompt.error(res.error) if res.error
      prompt.ok("#{story.id} started")
    end

    # TODO: Refactor story start and unstart due to similarities
    def story_unstart
      stories = @tracker.get_stories('started')
      options = {}
      stories.each do |s|
        options[s.to_s] = s
      end
      story = prompt.select('Choose the feature you want to unstart:', options, filter: true)
      return unless story
      res = story.update_state('unstarted')
      prompt.error(res.error) if res.error
      prompt.ok("#{story.id} unstarted")
    end

    private

    def prompt
      return @prompt if @prompt
      @prompt = TTY::Prompt.new
    end

    def finish_tag
      return @finish_tag if @finish_tag
      fallback = @global_config.fetch(project_id,
                                      :finish_tag,
                                      default: 'Finishes')
      @finish_tag = @local_config.fetch(:finish_tag, default: fallback)
      @finish_tag
    end

    def create_feature_branch(story)
      return if story.nil?
      current_branch = GitUtils.current_branch
      prompt.say "You are checked out at: #{current_branch}"
      feature_branch_name = prompt.ask('Provide a new branch name',
                                       default: story.dashed_title)
      feature_branch_name.chomp!
      return unless validate_branch_name(feature_branch_name, story.id)
      feature_branch_name_with_story_id = "#{feature_branch_name}-#{story.id}"
      prompt.say("Creating: #{feature_branch_name_with_story_id} with #{current_branch} as parent")
      GitUtils.create_branch feature_branch_name_with_story_id
    end

    # Branch name validation
    def validate_branch_name(name, id)
      if GitUtils.existing_story? id
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

# frozen_string_literal: true

require_relative './string_utils'
require_relative './pivotal_utils'
require_relative './config_manager'
require 'tty-prompt'

module StoryBranch
  # Main story branch class. It is resposnible for the main interaction between
  # the user and Pivotal Tracker. It is also responsible for config init.
  class Main
    ERRORS = {
      'Stories in the started state must be estimated.' =>
      "Error: Pivotal won't allow you to start an unestimated story"
    }.freeze

    attr_accessor :p

    def initialize
      @p = PivotalUtils.new
      @p.project_id = project_id
      @p.api_key = config.fetch(project_id, :api_key)
      @p.finish_tag = config.fetch(project_id, :finish_tag, default: 'Finishes')
      exit unless @p.valid?
    end

    # TODO:
    # Move these methods to the command logic.
    def create_story_branch
      prompt.say 'Connecting with Pivotal Tracker'
      @p.project
      prompt.say 'Getting stories...'
      stories = @p.display_stories :started, false
      if stories.empty?
        prompt.say 'No stories started, exiting'
        exit
      end
      story = @p.select_story stories
      return unless story
      @p.create_feature_branch story
    rescue Blanket::Unauthorized
      unauthorised_message
      return nil
    end

    def story_finish
      prompt.say 'Connecting with Pivotal Tracker'
      @p.project

      unless @p.is_current_branch_a_story?
        warn "Your current branch: '#{GitUtils.current_branch}' is not linked to a Pivotal Tracker story."
        return nil
      end

      if GitUtils.status?(:untracked) || GitUtils.status?(:modified)
        prompt.say 'There are unstaged changes'
        prompt.say 'Use git add to stage changes before running git finish'
        prompt.say 'Use git stash if you want to hide changes for this commit'
        return nil
      end

      unless GitUtils.status?(:added) || GitUtils.status?(:staged)
        prompt.say 'There are no staged changes.'
        prompt.say 'Nothing to do'
        return nil
      end

      current_story = GitUtils.current_branch_story_parts
      commit_message = "[#{@p.finish_tag} ##{current_story[:id]}] "\
        "#{StoryBranch::StringUtils.undashed(current_story[:title])}"

      prompt.say(commit_message)
      abort_commit = prompt.no?('Use standard finishing commit message?')
      if abort_commit
        prompt.say 'Aborted'
      else
        GitUtils.commit commit_message
      end
    rescue Blanket::Unauthorized
      unauthorised_message
      return nil
    end

    def story_start
      pick_and_update(:unstarted, { current_state: 'started' }, 'started', true)
    end

    def story_unstart
      pick_and_update(:started, { current_state: 'unstarted' }, 'unstarted', false)
    end

    private

    def prompt
      return @prompt if @prompt
      @prompt = TTY::Prompt.new
    end

    def config
      return @config if @config
      @config = ConfigManager.init_config(Dir.home)
      @config
    end

    def project_id
      return @project_id if @project_id
      local_config = ConfigManager.init_config('.')
      @project_id = local_config.fetch(:project_id)
      @project_id
    end

    def unauthorised_message
      warn 'Pivotal API key or Project ID invalid'
    end

    def pick_and_update(filter, hash, msg, is_estimated)
      puts 'Connecting with Pivotal Tracker'
      @p.project
      puts 'Getting stories...'
      stories = @p.filtered_stories_list filter, is_estimated
      story = @p.select_story stories
      if story
        result = @p.story_update story, hash
        raise result.error if result.error
        puts "#{story.id} #{msg}"
      end
    rescue Blanket::Unauthorized
      unauthorised_message
      return nil
    end

    def story_estimate
      # TODO: estimate a story
    end
  end
end

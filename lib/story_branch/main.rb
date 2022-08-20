# frozen_string_literal: true

require 'story_branch/git_wrapper'
require_relative './git_utils'
require_relative './config_manager'
require_relative './url_opener'
require_relative 'tracker_initializer'

require 'tty-prompt'

module StoryBranch
  # Main story branch class. It is responsible for the main interaction between
  # the user and Pivotal Tracker. It is also responsible for config init.

  # rubocop:disable Metrics/ClassLength
  class Main
    attr_accessor :tracker

    def initialize
      @config = ConfigManager.new
      abort(@config.errors.join("\n")) unless @config.valid?
      @tracker = StoryBranch::TrackerInitializer.initialize_tracker(config: @config)
      abort('Invalid tracker configuration setting.') unless @tracker.valid?
    end

    def create_story_branch
      stories = @tracker.stories
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
      return unless current_story
      return if unstaged_changes?
      return if nothing_to_add?

      commit_message = build_finish_message
      proceed = prompt.yes?("Commit with standard message? #{commit_message}")
      if proceed
        GitWrapper.commit commit_message
      else
        prompt.say 'Aborted'
      end
    end

    # NOTE: This feature is only available for pivotal tracker at the moment
    # as for github there is no use case
    def story_start
      return unless require_pivotal

      story = update_status('unstarted', 'started', 'start')
      create_feature_branch story
    end

    # NOTE: This feature is only available for pivotal tracker at the moment
    # as for github there is no use case
    def story_unstart
      return unless require_pivotal

      update_status('started', 'unstarted', 'unstart')
    end

    def open_current_url
      if current_story
        prompt.say 'Opening story in browser...'
        StoryBranch::UrlOpener.open_url(current_story.html_url)
      else
        prompt.say 'Could not find matching story in configured tracker'
      end
    end

    private

    def require_pivotal
      return true if @tracker.class.name.match?('Pivotal')

      prompt.say 'The configured tracker does not support this feature'
      false
    end

    def current_story
      return nil unless @tracker

      @tracker.current_story
    end

    def unstaged_changes?
      return false unless GitUtils.status?(:untracked) || GitUtils.status?(:modified)

      message = <<~MESSAGE
        There are unstaged changes
        Use git add to stage changes before running git finish
        Use git stash if you want to hide changes for this commit
      MESSAGE
      prompt.say message
    end

    def nothing_to_add?
      return false if GitUtils.status?(:added) || GitUtils.status?(:staged)

      message = <<~MESSAGE
        There are no staged changes.
        Nothing to do.
      MESSAGE
      prompt.say message
      true
    end

    # rubocop:disable Metrics/MethodLength
    def update_status(current_status, next_status, action)
      stories = @tracker.stories_with_state(current_status)
      if stories.empty?
        prompt.say "No #{current_status} stories, exiting"
        return
      end
      options = build_stories_structure(stories)
      story = prompt.select(
        "Choose the feature you want to #{action}:",
        options,
        filter: true
      )
      return unless story

      res = story.update_state(next_status)
      if res.error&.present?
        prompt.error(res.error)
        return
      end
      prompt.ok("#{story.id} #{next_status}")
      story
    end
    # rubocop:enable Metrics/MethodLength

    def build_stories_structure(stories)
      options = {}
      stories.each do |s|
        options[s.to_s] = s
      end
      options
    end

    def prompt
      @prompt ||= TTY::Prompt.new(interrupt: :exit)
    end

    def build_finish_message
      message_tag = [@config.finish_tag, "##{current_story.id}"].join(' ').strip
      "[#{message_tag}] #{current_story.title}"
    end

    def create_feature_branch(story)
      return if story.nil?

      branch_name = valid_branch_name(story)
      return unless branch_name

      feature_branch_name_with_story_id = build_branch_name(branch_name, story.id)

      prompt.say("Creating: #{feature_branch_name_with_story_id} with #{current_branch} as parent")
      GitWrapper.create_branch feature_branch_name_with_story_id
    end

    def valid_branch_name(story)
      prompt.say "You are checked out at: #{current_branch}"
      branch_name = prompt.ask('Provide a new branch name', default: story.dashed_title)
      feature_branch_name = StringUtils.truncate(branch_name.chomp)

      validate_branch_name(feature_branch_name)
    end

    # Branch name validation
    # rubocop:disable Metrics/MethodLength
    def validate_branch_name(name)
      if GitUtils.similar_branch? name
        prompt.warn('This name is very similar to an existing branch. It is recommended to use a more unique name.')
        decision = prompt.select('What to do?') do |menu|
          menu.choice 'Rename the branch', 1
          menu.choice 'Proceed with branch name', 2
          menu.choice 'Abort branch creation', 3
        end
        return nil if decision == 3
        return name if decision == 2

        return prompt.ask('Provide a new branch name', default: name)
      end
      name
    end
    # rubocop:enable Metrics/MethodLength

    def build_branch_name(branch_name, story_id)
      branch_name = if @config.issue_placement.casecmp('beginning').zero?
                      "#{story_id}-#{branch_name}"
                    else
                      "#{branch_name}-#{story_id}"
                    end
      return branch_name unless @config.branch_username

      "#{@config.branch_username}/#{branch_name}"
    end

    def current_branch
      @current_branch ||= GitWrapper.current_branch
    end
  end
  # rubocop:enable Metrics/ClassLength
end

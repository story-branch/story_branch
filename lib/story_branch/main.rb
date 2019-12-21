# frozen_string_literal: true

require_relative './pivotal/tracker'
require_relative './github/tracker'
require_relative './jira/tracker'
require_relative './git_utils'
require_relative './git_wrapper'
require_relative './config_manager'
require 'tty-prompt'

module StoryBranch
  # Main story branch class. It is responsible for the main interaction between
  # the user and Pivotal Tracker. It is also responsible for config init.

  # rubocop:disable Metrics/ClassLength
  class Main
    attr_accessor :tracker

    def initialize
      # TODO: Config manager should be responsible for handling the
      # configuration and the story branch should only initialize one
      # config manager that has attr accessors for needed values
      # Read local config and decide what Utility to use
      # (e.g. PivotalUtils, GithubUtils, ...)
      @local_config = ConfigManager.init_config('.')
      @global_config = ConfigManager.init_config(Dir.home)
      initialize_tracker
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
      current_story
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

    private

    def require_pivotal
      if @tracker.type != 'pivotal'
        prompt.say 'The configured tracker does not support this feature'
        return false
      end
      true
    end

    def current_story
      return @current_story if @current_story

      current_story = GitUtils.current_branch_story_parts

      unless current_story.empty?
        @current_story = @tracker.get_story_by_id(current_story[:id])
        return @current_story if @current_story
      end

      prompt.error('No tracked feature associated with this branch')
    end

    def unstaged_changes?
      unless GitUtils.status?(:untracked) || GitUtils.status?(:modified)
        return false
      end

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

    # rubocop:disable Metrics/AbcSize
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
    # rubocop:enable Metrics/AbcSize

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

    def finish_tag
      return @finish_tag if @finish_tag

      fallback = @global_config.fetch(project_id,
                                      :finish_tag,
                                      default: 'Finishes')
      @finish_tag = @local_config.fetch(:finish_tag, default: fallback)
      @finish_tag
    end

    def issue_placement
      return @issue_placement if @issue_placement

      fallback = @global_config.fetch(project_id,
                                      :issue_placement,
                                      default: 'End')
      @issue_placement = @local_config.fetch(:issue_placement,
                                             default: fallback)
      @issue_placement
    end

    def build_finish_message
      message_tag = [finish_tag, "##{current_story.id}"].join(' ').strip
      "[#{message_tag}] #{current_story.title}"
    end

    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/MethodLength
    def create_feature_branch(story)
      return if story.nil?

      current_branch = GitWrapper.current_branch
      prompt.say "You are checked out at: #{current_branch}"
      branch_name = prompt.ask('Provide a new branch name',
                               default: story.dashed_title)
      feature_branch_name = StringUtils.truncate(branch_name.chomp)
      return unless validate_branch_name(feature_branch_name, story.id)

      feature_branch_name_with_story_id = build_branch_name(
        feature_branch_name, story.id
      )
      # rubocop:disable Metrics/LineLength
      prompt.say("Creating: #{feature_branch_name_with_story_id} with #{current_branch} as parent")
      # rubocop:enable Metrics/LineLength
      GitWrapper.create_branch feature_branch_name_with_story_id
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/MethodLength

    def build_branch_name(branch_name, story_id)
      if issue_placement.casecmp('beginning').zero?
        "#{story_id}-#{branch_name}"
      else
        "#{branch_name}-#{story_id}"
      end
    end

    # Branch name validation
    def validate_branch_name(name, id)
      if GitUtils.branch_for_story_exists? id
        prompt.error("An existing branch has the same story id: #{id}")
        return false
      end
      if GitUtils.existing_branch? name
        # rubocop:disable Metrics/LineLength
        prompt.error('This name is very similar to an existing branch. Avoid confusion and use a more unique name.')
        # rubocop:enable Metrics/LineLength
        return false
      end
      true
    end

    def project_id
      return @project_id if @project_id

      project_ids = @local_config.fetch(:project_id)
      @project_id = choose_project_id(project_ids)
    end

    def choose_project_id(project_ids)
      return project_ids unless project_ids.is_a? Array
      return project_ids[0] unless project_ids.length > 1

      prompt.select('Which project you want to fetch from?', project_ids)
    end

    def api_key
      @api_key ||= @global_config.fetch(project_id, :api_key)
    end

    def username
      @username ||= @global_config.fetch(project_id, :username)
    end

    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/MethodLength
    def initialize_tracker
      if project_id.nil?
        prompt.say 'Project ID not set'
        exit 0
      end
      tracker_type = @local_config.fetch(:tracker, default: 'pivotal-tracker')
      @tracker = case tracker_type
                 when 'github'
                   StoryBranch::Github::Tracker.new(project_id, api_key)
                 when 'pivotal-tracker'
                   StoryBranch::Pivotal::Tracker.new(project_id, api_key)
                 when 'jira'
                   tracker_domain, project_key = project_id.split('|')
                   options = {
                     tracker_domain: tracker_domain,
                     project_id: project_key,
                     api_key: api_key,
                     username: username
                   }
                   StoryBranch::Jira::Tracker.new(options)
                 end
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/MethodLength
  end
  # rubocop:enable Metrics/ClassLength
end

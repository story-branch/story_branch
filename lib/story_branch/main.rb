require_relative './string_utils'
require_relative './pivotal_utils'
require_relative './config_manager'

module StoryBranch
  class Main
    ERRORS = {
      'Stories in the started state must be estimated.' =>
      "Error: Pivotal won't allow you to start an unestimated story"
    }.freeze

    attr_accessor :p

    def initialize
      @p = PivotalUtils.new
      @p.api_key = config.fetch(project_name, :api_key)
      @p.project_id = config.fetch(project_name, :project_id)
      @p.finish_tag = config.fetch(project_name, :finish_tag, default: 'Finishes')
      exit unless @p.valid?
    end

    # TODO:
    # Move these methods to the command logic.
    def create_story_branch
      puts 'Connecting with Pivotal Tracker'
      @p.project
      puts 'Getting stories...'
      stories = @p.display_stories :started, false
      if stories.empty?
        puts 'No stories started, exiting'
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
      puts 'Connecting with Pivotal Tracker'
      @p.project

      unless @p.is_current_branch_a_story?
        puts "Your current branch: '#{GitUtils.current_branch}' is not linked to a Pivotal Tracker story."
        return nil
      end

      if GitUtils.status?(:untracked) || GitUtils.status?(:modified)
        puts 'There are unstaged changes'
        puts 'Use git add to stage changes before running git finish'
        puts 'Use git stash if you want to hide changes for this commit'
        return nil
      end

      unless GitUtils.status?(:added) || GitUtils.status?(:staged)
        puts 'There are no staged changes.'
        puts 'Nothing to do'
        return nil
      end

      puts 'Use standard finishing commit message: [y/N]?'
      commit_message = "[Finishes ##{GitUtils.current_branch_story_parts[:id]}] #{StoryBranch::StringUtils.undashed GitUtils.current_branch_story_parts[:title]}"
      puts commit_message

      if gets.chomp!.casecmp('y').zero?
        GitUtils.commit commit_message
      else
        puts 'Aborted'
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

    def config
      return @config if @config
      @config = ConfigManager.init_config(Dir.home)
      @config
    end

    def project_name
      return @project_name if @project_name
      local_config = ConfigManager.init_config('.')
      @project_name = local_config.fetch(:project_name)
      @project_name
    end

    def unauthorised_message
      $stderr.puts 'Pivotal API key or Project ID invalid'
    end

    def pick_and_update(filter, hash, msg, is_estimated)
      puts 'Connecting with Pivotal Tracker'
      @p.project
      puts 'Getting stories...'
      stories = @p.filtered_stories_list filter, is_estimated
      story = @p.select_story stories
      if story
        result = @p.story_update story, hash
        fail result.error if result.error
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

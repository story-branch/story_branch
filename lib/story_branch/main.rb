require_relative './string_utils'
require_relative './pivotal_utils'
require 'tty-config'

class StoryBranch::Main
  include StoryBranch

  ERRORS = {
    'Stories in the started state must be estimated.' =>
    "Error: Pivotal won't allow you to start an unestimated story"
  }

  attr_accessor :p

  def initialize
    @p = PivotalUtils.new
    @p.api_key = config.fetch(project_name, :api_key)
    @p.project_id = config.fetch(project_name, :project_id)
    @p.finish_tag = config.fetch(project_name, :finish_tag, default: 'Finishes')
    exit unless @p.valid?
  end

  def create_story_branch
    puts 'Connecting with Pivotal Tracker'
    @p.get_project
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
    @p.get_project
    unless @p.is_current_branch_a_story?
      puts "Your current branch: '#{GitUtils.current_branch}' is not linked to a Pivotal Tracker story."
      return nil
    end

    if GitUtils.has_status? :untracked or GitUtils.has_status? :modified
      puts 'There are unstaged changes'
      puts 'Use git add to stage changes before running git finish'
      puts 'Use git stash if you want to hide changes for this commit'
      return nil
    end

    unless GitUtils.has_status? :added or GitUtils.has_status? :staged
      puts 'There are no staged changes.'
      puts 'Nothing to do'
      return nil
    end

    puts 'Use standard finishing commit message: [y/N]?'

    commit_message = "[#{@p.finish_tag} ##{GitUtils.current_branch_story_parts[:id]}] #{StringUtils.undashed GitUtils.current_branch_story_parts[:title]}"
    puts commit_message

    if gets.chomp!.downcase == 'y'
      GitUtils.commit commit_message
    else
      puts 'Aborted'
    end
  rescue Blanket::Unauthorized
    unauthorised_message
    return nil
  end

  private

  def config
    return @config if @config
    @config = TTY::Config.new
    @config.append_path(ENV['HOME'])
    @config.filename = '.story_branch'
    @config.read
    @config
  end

  def project_name
    return @project_name if @project_name
    local_config = TTY::Config.new
    local_config.append_path('.')
    local_config.filename = '.story_branch'
    local_config.read
    @project_name = local_config.fetch(:project_name)
  end

  def unauthorised_message
    $stderr.puts 'Pivotal API key or Project ID invalid'
  end

  def pick_and_update(filter, hash, msg, is_estimated)
    puts 'Connecting with Pivotal Tracker'
    @p.get_project
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

  def story_start
    pick_and_update(:unstarted, { current_state: 'started' }, 'started', true)
  end

  def story_unstart
    pick_and_update(:started, { current_state: 'unstarted' }, 'unstarted', false)
  end

  def story_estimate
    # TODO: estimate a story
  end
end

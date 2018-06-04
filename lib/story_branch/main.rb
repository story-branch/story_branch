class StoryBranch::Main

  include StoryBranch

  ERRORS = {
    'Stories in the started state must be estimated.' =>
    "Error: Pivotal won't allow you to start an unestimated story"
  }

  PIVOTAL_CONFIG_FILES = ['.story_branch', "#{ENV['HOME']}/.story_branch"]

  attr_accessor :p

  def initialize
    @p = PivotalUtils.new
    @p.api_key = config_value 'api', 'PIVOTAL_API_KEY'
    @p.project_id = config_value 'project', 'PIVOTAL_PROJECT_ID'
    @p.finish_tag = config_value 'finish_tag', 'PIVOTAL_FINISH_TAG', 'Finishes'
    exit unless @p.valid?
  end

  def unauthorised_message
    $stderr.puts 'Pivotal API key or Project ID invalid'
  end

  def create_story_branch
    begin
      puts 'Connecting with Pivotal Tracker'
      @p.get_project
      puts 'Getting stories...'
      stories = @p.display_stories :started, false
      if stories.length < 1
        puts 'No stories started, exiting'
        exit
      end
      story = @p.select_story stories
      if story
        @p.create_feature_branch story
      end
    rescue Blanket::Unauthorized
      unauthorised_message
      return nil
    end
  end

  def pick_and_update filter, hash, msg, is_estimated
    begin
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

  def story_finish
    begin
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
  end

  def config_value(key, env, default_value = nil)
    PIVOTAL_CONFIG_FILES.each do |config_file|
      if File.exist? config_file
        pivotal_info = YAML.load_file config_file
        return pivotal_info[key] if pivotal_info && pivotal_info[key]
      end
    end
    value ||= env_required(env, default_value)
    value
  end

  def env_required(var_name, default_value)
    return ENV[var_name] if ENV[var_name]
    return default_value if default_value
    $stderr.puts "$#{var_name} must be set or in .story_branch file"
    return nil
  end
end

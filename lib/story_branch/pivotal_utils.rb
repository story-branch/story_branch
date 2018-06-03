require 'blanket'
require 'rb-readline'
require_relative './git_utils'

module StoryBranch
  class PivotalUtils
    API_URL = 'https://www.pivotaltracker.com/services/v5/'.freeze
    attr_accessor :api_key, :project_id, :finish_tag

    def valid?
      !@api_key.nil? && !@project_id.nil?
    end

    def api
      fail 'API key must be specified' unless @api_key
      Blanket.wrap API_URL, headers: { 'X-TrackerToken' => @api_key }
    end

    def project
      return @project if @project
      fail 'Project ID must be set' unless @project_id
      @project = api.projects(@project_id.to_i)
      @project
    end

    def story_accessor
      project.stories
    end

    def is_current_branch_a_story?
      StoryBranch::GitUtils.current_story and
        StoryBranch::GitUtils.current_story.length == 3 and
        filtered_stories_list(:started, true)
          .map(&:id)
          .include? StoryBranch::GitUtils.current_story[2].to_i
    end

    def story_from_current_branch
      story_accessor.get(StoryBranch::GitUtils.current_story[2].to_i) if StoryBranch::GitUtils.current_story.length == 3
    end

    # TODO: Maybe add some other predicates
    # - Filtering on where a story lives (Backlog, IceBox)
    # - Filtering on labels
    # as the need arises...
    #
    def filtered_stories_list(state, estimated)
      options = { with_state: state.to_s }
      stories = [* story_accessor.get(params: options).payload]
      if estimated
        stories.select do |s|
          s.story_type == 'bug' || s.story_type == 'chore' ||
            (s.story_type == 'feature' && s.estimate && s.estimate >= 0)
        end
      else
        stories
      end
    end

    def display_stories(state, estimated)
      filtered_stories_list(state, estimated).each {|s| puts one_line_story s }
    end

    def one_line_story(s)
      "#{s.id} - #{s.name}"
    end

    # TODO: Use TTY prompt with pagination
    def select_story(stories)
      story_texts = stories.map { |s| one_line_story s }
      puts 'Leave blank to exit, use <up>/<down> to scroll through stories, TAB to list all and auto-complete'
      story_selection = readline('Select a story: ', story_texts)
      return nil if story_selection == '' || story_selection.nil?
      story = stories.select { |s| story_matcher s, story_selection }.first
      if story.nil?
        puts "Not found: #{story_selection}"
        return nil
      else
        puts "Selected : #{one_line_story story}"
        return story
      end
    end

    def story_update(story, hash)
      project.stories(story.id).put(body: hash).payload
    end

    def story_matcher(story, selection)
      m = selection.match(/^(\d*) /)
      return false unless m
      id = m.captures.first
      story.id.to_s == id
    end

    def create_feature_branch(story)
      dashed_story_name = StoryBranch::StringUtils.normalised_branch_name story.name
      feature_branch_name = nil
      puts "You are checked out at: #{StoryBranch::GitUtils.current_branch}"
      while feature_branch_name.nil? || feature_branch_name == ''
        puts 'Provide a new branch name... (TAB for suggested name)' if [nil, ''].include? feature_branch_name
        feature_branch_name = readline('Name of feature branch: ', [dashed_story_name])
      end
      feature_branch_name.chomp!
      return unless validate_branch_name(feature_branch_name, story.id)
      feature_branch_name_with_story_id = "#{feature_branch_name}-#{story.id}"
      puts "Creating: #{feature_branch_name_with_story_id} with #{StoryBranch::GitUtils.current_branch} as parent"
      StoryBranch::GitUtils.create_branch feature_branch_name_with_story_id
    end

    # Branch name validation
    def validate_branch_name name, id
      if StoryBranch::GitUtils.is_existing_story? id
        puts "Error: An existing branch has the same story id: #{id}"
        return false
      end
      if StoryBranch::GitUtils.is_existing_branch? name
        puts 'Error: This name is very similar to an existing branch. Avoid confusion and use a more unique name.'
        return false
      end
      unless valid_branch_name? name
        puts "Error: #{name}\nis an invalid name."
        return false
      end
      true
    end

    def valid_branch_name?(name)
      # Valid names begin with a letter and are followed by alphanumeric
      # with _ . - as allowed punctuation
      valid = /[a-zA-Z][-._0-9a-zA-Z]*/
      name.match valid
    end

    def readline(prompt, completions = [])
      # Store the state of the terminal
      RbReadline.clear_history
      if completions.length.positive?
        completions.each { |i| Readline::HISTORY.push i }
        RbReadline.rl_completer_word_break_characters = ''
        Readline.completion_proc = proc { |s| completions.grep(/#{Regexp.escape(s)}/) }
        Readline.completion_append_character = ''
      end
      Readline.readline(prompt, false)
    end
  end
end

# frozen_string_literal: true

require 'blanket'
require 'rb-readline'
require_relative './string_utils'

module StoryBranch
  # PivotalTracker Story representation
  class Story
    attr_accessor :title, :id

    def initialize(blanket_story)
      @story = blanket_story
      @title = blanket_story.name
      @id = blanket_story.id
    end

    def update_state(new_state)
      params = { current_state: new_state }
      @story.put(body: params).payload
    end

    def to_s
      "#{@id} - #{@title}"
    end

    def dashed_title
      StoryBranch::StringUtils.normalised_branch_name @title
    end
  end

  # PivotalTracker Project representation
  class Project
    def initialize(blanket_project)
      @project = blanket_project
    end

    # NOTE: takes in possible keys:
    # - with_state
    # - estimated
    # Returns an array of PT Stories (Story Class)
    # TODO: add other possible args
    def stories(options = {})
      params = { with_state: options.with_state }
      stories = @project.stories.get(params: params).payload
      stories.map { |s| Story.new(s) }
    end
  end

  # Utility class for integration with PivotalTracker. It relies on Blanket
  # wrapper to communicate with pivotal tracker's api.
  class PivotalUtils
    API_URL = 'https://www.pivotaltracker.com/services/v5/'

    def initialize(local_config, global_config)
      @local_config = local_config
      @global_config = global_config
    end

    def valid?
      !api_key.nil? && !project_id.nil?
    end

    # TODO: Maybe add some other predicates
    # - Filtering on where a story lives (Backlog, IceBox)
    # - Filtering on labels
    # - Filtering on story type
    def get_stories(state)
      @project.stories(with_state: state)
    end

    def get_story_by_id(story_id)
      @project.stories(id: story_id).first
    end

    private

    def api
      fail 'API key must be specified' unless @api_key
      Blanket.wrap API_URL, headers: { 'X-TrackerToken' => @api_key }
    end

    def api_key
      return @api_key if @api_key
      @api_key = @global_config.fetch(project_id, :api_key)
      @api_key
    end

    def project_id
      return @project_id if @project_id
      @project_id = @local_config.fetch(:project_id)
      @project_id
    end

    def project
      return @project if @project
      fail 'Project ID must be set' unless @project_id
      blanket_project = api.projects(@project_id.to_i)
      @project = Project.new blanket_project
      @project
    end
  end
end

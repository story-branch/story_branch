# frozen_string_literal: true

module StoryBranch
  # Base story branch tracker class that will define the expected interface
  class TrackerBase
    TYPE = 'undefined'

    attr_reader :type

    def initialize(_options = {})
      @type = TYPE
    end

    def valid?
      raise 'valid? > must be implemented in the custom tracker'
    end

    # TODO: This should probably be renamed to something more meaningful
    # in the sense that it should be workable stories/issues
    # which depend on the tracker's workflow. PivotalTracker they need to
    # be started and estimated, while for Github they just need to be open
    def stories
      []
    end

    def get_story_by_id(_story_id)
      []
    end

    private

    def api
      raise 'API key must be specified' unless @api_key

      @api ||= configure_api
    end

    def project
      return @project if @project
      raise 'project key must be set' unless @project_id

      raise 'project > must be implemented in the custom tracker'
    end
  end
end

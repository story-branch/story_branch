# frozen_string_literal: true

module StoryBranch
  # Base story branch tracker class that will define the expected interface
  class TrackerBase
    def initialize(_options = {})
      @issue_regex = new Regexp('(\\d+)')
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

    def current_story
      return @current_story if @current_story

      story_from_branch = GitUtils.branch_to_story_string(@issue_regex)
      if story_from_branch.length == 2
        @current_story = get_story_by_id(story_from_branch[0])
        return @current_story
      end
      prompt.error('No tracked feature associated with this branch')
      nil
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

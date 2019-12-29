# frozen_string_literal: true

require 'blanket'
require_relative './project'

module StoryBranch
  module Pivotal
    # Utility class for integration with PivotalTracker. It relies on Blanket
    # wrapper to communicate with pivotal tracker's api.
    class Tracker
      API_URL = 'https://www.pivotaltracker.com/services/v5/'
      TYPE = 'pivotal'

      attr_reader :type

      def initialize(_options, project_id:, api_key:, **)
        @project_id = project_id
        @api_key = api_key
        @type = TYPE
      end

      def valid?
        !@api_key.nil? && !@project_id.nil?
      end

      # TODO: This should probably be renamed to something more meaningful
      # in the sense that it should be workable stories/issues
      # which depend on the tracker's workflow. PivotalTracker they need to
      # be started and estimated, while for Github they just need to be open
      def stories
        stories_with_state('started')
      end

      def stories_with_state(state)
        project.stories(with_state: state)
      end

      def get_story_by_id(story_id)
        project.stories(id: story_id).first
      end

      private

      def api
        raise 'API key must be specified' unless @api_key

        Blanket.wrap API_URL, headers: { 'X-TrackerToken' => @api_key }
      end

      def project
        return @project if @project
        raise 'Project ID must be set' unless @project_id

        blanket_project = api.projects(@project_id.to_i)
        @project = Project.new blanket_project
        @project
      end
    end
  end
end

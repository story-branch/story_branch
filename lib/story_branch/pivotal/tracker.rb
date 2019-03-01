# frozen_string_literal: true

require 'blanket'
require_relative './project'

module StoryBranch
  module Pivotal
    # Utility class for integration with PivotalTracker. It relies on Blanket
    # wrapper to communicate with pivotal tracker's api.
    class Tracker
      API_URL = 'https://www.pivotaltracker.com/services/v5/'

      def initialize(project_id, api_key)
        @project_id = project_id
        @api_key = api_key
      end

      def valid?
        !@api_key.nil? && !@project_id.nil?
      end

      def get_stories(state)
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

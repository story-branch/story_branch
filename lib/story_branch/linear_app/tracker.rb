# frozen_string_literal: true

require 'story_branch/graphql'
require_relative '../tracker_base'
require_relative 'team'

module StoryBranch
  module LinearApp
    # Linear App API wrapper for story branch tracker
    class Tracker < StoryBranch::TrackerBase
      API_URL = 'https://api.linear.app/'

      def initialize(project_id:, api_key:, **)
        super

        # NOTE: project should be the representation of linear app team
        @team_id = project_id
        @api_key = api_key
        @issue_regex = Regexp.new("#{@team_id}-(\\d+)")
      end

      def valid?
        !@api_key.nil? && !@team_id.nil?
      end

      # TODO: This should probably be renamed to something more meaningful
      # in the sense that it should be workable stories/issues
      # which depend on the tracker's workflow. PivotalTracker they need to
      # be started and estimated, while for Github they just need to be open
      def stories
        project.stories
      end

      def get_story_by_id(story_id)
        project.stories(id: story_id).first
      end

      def client
        @client ||= StoryBranch::Graphql::Client.new(api_url: API_URL, api_key: @api_key)
      end

      private

      def configure_api
        client
      end

      def project
        return @project if @project
        raise 'team must be set' unless @team_id

        @project = Team.new(@team_id, client)
      end
    end
  end
end

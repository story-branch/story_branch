# frozen_string_literal: true

require 'blanket'
require_relative '../tracker_base'
require_relative './project'

module StoryBranch
  module Github
    # Github API wrapper for story branch tracker
    class Tracker < StoryBranch::TrackerBase
      API_URL = 'https://api.github.com/'

      def initialize(project_id:, api_key:, **)
        super
        # NOTE: RepoName should follow owner/repo_name format
        @repo_name = project_id
        @api_key = api_key
      end

      def valid?
        !@api_key.nil? && !@repo_name.nil?
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

      private

      def configure_api
        Blanket.wrap API_URL, headers: {
          'User-Agent' => 'Story Branch',
          Authorization: "token #{@api_key}"
        }
      end

      def project
        return @project if @project
        raise 'repo name must be set' unless @repo_name

        blanket_project = api.repos(@repo_name)
        @project = Project.new blanket_project
      end
    end
  end
end

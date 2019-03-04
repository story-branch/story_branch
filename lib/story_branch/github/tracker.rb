# frozen_string_literal: true

require 'blanket'
require_relative './project'

module StoryBranch
  module Github
    # Github API wrapper for story branch tracker
    class Tracker
      API_URL = 'https://api.github.com/'

      def initialize(repo_name, api_key)
        # NOTE: RepoName should follow owner/repo_name format
        @repo_name = repo_name
        @api_key = api_key
      end

      def valid?
        !@api_key.nil? && !@repo_name.nil?
      end

      def stories
        project.stories
      end

      def get_story_by_id(story_id)
        project.stories(id: story_id).first
      end

      private

      def api
        raise 'API key must be specified' unless @api_key

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

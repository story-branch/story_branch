# frozen_string_literal: true

# NOTE: The JIRA api is restful but I don't seem to be able to wrap it
# with blanket, so I'm using a gem that has wrapped the whole api, but
# my tracker and issues will still provide a similar api. This jira-ruby
# is used to get the data.
require 'jira-ruby'
require_relative './project'

module StoryBranch
  module Jira
    # JIRA API wrapper for story branch tracker
    class Tracker
      TYPE = 'jira'

      attr_reader :type

      def initialize(tracker_domain:, project_id:, api_key:, username:)
        @tracker_url = "https://#{tracker_domain}.atlassian.net"
        @project_id = project_id
        @api_key = api_key
        @username = username
        @type = TYPE
      end

      def valid?
        [@api_key, @project_id, @username, @tracker_url].none?(&:nil?)
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

      def options
        {
          username: @username,
          password: @api_key,
          site: @tracker_url,
          auth_type: :basic,
          read_timeout: 120,
          context_path: ''
        }
      end

      def api
        raise 'API key must be specified' unless @api_key

        @api ||= JIRA::Client.new(options)
      end

      def project
        return @project if @project
        raise 'project key must be set' unless @project_id

        jira_project = api.Project.find(@project_id)
        @project = Project.new(jira_project)
      end
    end
  end
end

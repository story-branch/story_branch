# frozen_string_literal: true

require_relative './issue'

module StoryBranch
  module Jira
    # Jira Project representation
    class Project
      def initialize(jira_project, api)
        @project = jira_project
        @api = api
      end

      # Returns an array of Jira issues (Issue Class)
      # TODO: add other possible args
      def stories(options = {})
        stories = @api.Issue.jql("project=#{@project.key} AND status='To Do' AND assignee=currentUser()")
        # stories = if options[:id]
        #             [@project.issues.find(options[:id])]
        #           else

        #             options[:fields] ||= query_todo
        #             puts options
        #             @project.issues(options)
        #           end
        stories.map { |s| Issue.new(s, @project) }
      end

      private

      def query_todo
        "status = 'To Do'"
      end

      def query_assigned_to_me
        { assignee_in: '(rui)' }
      end
    end
  end
end

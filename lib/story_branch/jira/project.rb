# frozen_string_literal: true

require_relative './issue'

module StoryBranch
  module Jira
    # Jira Project representation
    class Project
      def initialize(jira_project, query_addon = '')
        @project = jira_project
        @query_addon = query_addon
      end

      # Returns an array of Jira issues (Issue Class)
      # TODO: Support different options being passed.
      # Probably will need a specific query builder per tracker
      def stories(options = {})
        stories = if options[:id]
                    [@project.issues.find(options[:id])]
                  else
                    @project.client.Issue.jql(jql_query)
                  end

        stories.map { |s| Issue.new(s, @project) }
      end

      private

      def jql_query
        base_query = "project=#{@project.key} AND assignee=currentUser()"
        if @query_addon.length.positive?
          [base_query, @query_addon].join(' AND ')
        else
          base_query
        end
      end
    end
  end
end

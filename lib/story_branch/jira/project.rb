# frozen_string_literal: true

require_relative './issue'

module StoryBranch
  module Jira
    # Jira Project representation
    class Project
      def initialize(jira_project)
        @project = jira_project
      end

      # Returns an array of Jira issues (Issue Class)
      # TODO: Support different options being passed.
      # Probably will need a specific query builder per tracker
      def stories(options = {})
        stories = if options[:id]
                    [@project.issues.find(options[:id])]
                  else
                    # rubocop:disable Metrics/LineLength
                    @project.client.Issue.jql(
                      "project=#{@project.key} AND status='To Do' AND assignee=currentUser()"
                    )
                    # rubocop:enable Metrics/LineLength
                  end

        stories.map { |s| Issue.new(s, @project) }
      end
    end
  end
end

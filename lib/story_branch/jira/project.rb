# frozen_string_literal: true

require_relative './issue'
require 'pry'

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
        stories = @project.client.Issue.jql(
          "project=#{@project.key} AND status='To Do' AND assignee=currentUser()"
        )
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

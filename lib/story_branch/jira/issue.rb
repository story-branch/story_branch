# frozen_string_literal: true

module StoryBranch
  module Jira
    # Jira Issue representation
    class Issue
      attr_accessor :title, :id

      # TODO: Add component and labels to the info of the issue
      def initialize(jira_issue, project)
        @project = project
        @story = jira_issue
        @title = jira_issue.summary
        @id = jira_issue.key
      end

      def update_state
        puts 'What to do in github for this?'
      end

      def to_s
        "#{@id} - #{@title}"
      end

      def dashed_title
        StoryBranch::StringUtils.normalised_branch_name @title
      end
    end
  end
end

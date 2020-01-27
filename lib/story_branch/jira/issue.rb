# frozen_string_literal: true

module StoryBranch
  module Jira
    # Jira Issue representation
    class Issue
      attr_accessor :title, :id, :html_url

      # TODO: Add component and labels to the info of the issue
      def initialize(jira_issue, project)
        binding.pry

        @project = project
        @story = jira_issue
        @title = jira_issue.summary
        @id = jira_issue.key
        @html_url = transform_url(jira_issue.self)
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

      private

      def transform_url(url)
        url.gsub(%r{rest\/api.*$}, "browse/#{@id}")
      end
    end
  end
end

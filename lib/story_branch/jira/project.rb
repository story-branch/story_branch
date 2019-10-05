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
      # TODO: add other possible args
      def stories(options = {})
        stories = if options[:id]
                    [@project.issues.find(options[:id])]
                  else
                    puts 'not yet implemented'
                    []
                    # @project.issues.get(params: options)
                  end
        stories.map { |s| Issue.new(s, @project) }
      end
    end
  end
end

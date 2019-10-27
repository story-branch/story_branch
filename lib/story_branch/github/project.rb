# frozen_string_literal: true

require_relative './issue'

module StoryBranch
  module Github
    # Github API Repository Representation
    class Project
      def initialize(blanket_project)
        @repo = blanket_project
      end

      def stories(options = {})
        stories = if options[:id]
                    [@repo.issues(options[:id]).get]
                  else
                    @repo.issues.get(params: options)
                  end
        stories.reject!(&:pull_request)
        stories.map { |s| Issue.new(s, @repo) }
      end
    end
  end
end

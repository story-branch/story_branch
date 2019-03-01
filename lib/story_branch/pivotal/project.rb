# frozen_string_literal: true

module StoryBranch
  module Pivotal
    # PivotalTracker Project representation
    class Project
      def initialize(blanket_project)
        @project = blanket_project
      end

      # Returns an array of PT Stories (Story Class)
      # TODO: add other possible args
      def stories(options = {}, estimated = true)
        stories = if options[:id]
                    [@project.stories(options[:id]).get.payload]
                  else
                    @project.stories.get(params: options).payload
                  end
        stories = stories.map { |s| Story.new(s, @project) }
        return stories if estimated == false

        stories.select(&:estimated)
      end
    end
  end
end

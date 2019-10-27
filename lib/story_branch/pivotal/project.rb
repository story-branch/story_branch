# frozen_string_literal: true

require_relative './story'

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
                    [@project.stories(options[:id]).get]
                  else
                    @project.stories.get(params: options)
                  end
        stories = stories.map { |s| Story.new(s, @project) }
        return stories if estimated == false

        stories.select(&:estimated)
      end
    end
  end
end

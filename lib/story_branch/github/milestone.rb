# frozen_string_literal: true

module StoryBranch
  module Github
    # Github Milestones representation
    class Milestone
      attr_accessor :id, :title, :description

      def initialize(milestone_data)
        @id = milestone_data.number
        @title = milestone_data.title
        @description = milestone_data.description
      end

      def to_s
        "MS: #{@title} - #{@description}"
      end
    end
  end
end

# frozen_string_literal: true

require_relative '../string_utils'

module StoryBranch
  module Pivotal
    # PivotalTracker Story representation
    class Story
      NON_ESTIMATED_TYPES = %w[chore bug release].freeze
      attr_accessor :title, :id

      def initialize(blanket_story, project)
        @project = project
        @story = blanket_story
        @title = blanket_story.name
        @id = blanket_story.id
        @story_type = blanket_story.story_type
        @estimate = blanket_story.estimate
      end

      def update_state(new_state)
        params = { current_state: new_state }
        @project.stories(@id).put(body: params).payload
      end

      def to_s
        "#{@id} - #{@title}"
      end

      def dashed_title
        StoryBranch::StringUtils.normalised_branch_name @title
      end

      def estimated
        (@story_type == 'feature' && !@estimate.nil?) ||
          NON_ESTIMATED_TYPES.include?(@story_type)
      end
    end
  end
end

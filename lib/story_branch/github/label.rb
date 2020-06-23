# frozen_string_literal: true

module StoryBranch
  module Github
    # Github Labels representation
    class Label
      attr_accessor :name, :color

      def initialize(label_data)
        @name = label_data.name
        @color = label_data.color
      end
    end
  end
end

# frozen_string_literal: true

require_relative '../command'

module StoryBranch
  module Commands
    # Create commant triggers the story branch logic.
    class Create < StoryBranch::Command
      def initialize(options)
        @options = options
      end

      def execute(_input: $stdin, _output: $stdout)
        require_relative '../main'
        sb = StoryBranch::Main.new
        sb.create_story_branch
      end
    end
  end
end

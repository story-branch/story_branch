# frozen_string_literal: true

require_relative '../command'

module StoryBranch
  module Commands
    # Command to finish a story
    class Finish < StoryBranch::Command
      def initialize(options)
        super()
        @options = options
      end

      def execute(_input: $stdin, _output: $stdout)
        require_relative '../main'
        sb = StoryBranch::Main.new
        sb.story_finish
      end
    end
  end
end

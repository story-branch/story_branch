# frozen_string_literal: true

require_relative '../command'

module StoryBranch
  module Commands
    class Start < StoryBranch::Command
      def initialize(options)
        @options = options
      end

      def execute(input: $stdin, output: $stdout)
        require_relative '../main'
        sb = StoryBranch::Main.new
        sb.story_start
      end
    end
  end
end

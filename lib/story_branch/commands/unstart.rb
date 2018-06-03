# frozen_string_literal: true

require_relative '../command'

module StoryBranch
  module Commands
    class Unstart < StoryBranch::Command
      def initialize(options)
        @options = options
      end

      def execute(input: $stdin, output: $stdout)
        require_relative '../main'
        sb = StoryBranch::Main.new
        sb.story_unstart
      end
    end
  end
end

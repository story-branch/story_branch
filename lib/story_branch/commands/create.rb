# frozen_string_literal: true

require_relative '../command'

module StoryBranch
  module Commands
    # Create command is used to create a branch from
    # started stories in the tracker
    class Create < StoryBranch::Command
      def initialize(options)
        super()
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

# frozen_string_literal: true

require_relative '../command'

module StoryBranch
  module Commands
    # OpenIssue command is used to open the associated ticket in the browser
    class OpenIssue < StoryBranch::Command
      def initialize(options)
        @options = options
      end

      def execute(_input: $stdin, _output: $stdout)
        require_relative '../main'
        sb = StoryBranch::Main.new
        sb.open_current_url
      end
    end
  end
end

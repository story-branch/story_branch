# frozen_string_literal: true

require_relative '../command'

module StoryBranch
  module Commands
    # OpenIssue command is used to open the associated ticket in the browser
    class OpenIssue < StoryBranch::Command
      def initialize(options)
        @options = options
      end

      def execute(_input: $stdin, output: $stdout)
        require_relative '../main'
        sb = StoryBranch::Main.new
        res = sb.open_current_url
        output.write(res)
      end
    end
  end
end

# frozen_string_literal: true

require 'thor'

module StoryBranch
  # Handle the application command line parsing
  # and the dispatch to various command objects
  #
  # @api public
  class CLI < Thor
    # Error raised by this runner
    Error = Class.new(StandardError)

    desc 'version', 'story_branch version'
    def version
      require_relative 'version'
      puts "v#{StoryBranch::VERSION}"
    end
    map %w(--version -v) => :version

    desc 'config', 'Command description...'
    method_option :help, aliases: '-h', type: :boolean,
                         desc: 'Display usage information'
    def config(*)
      if options[:help]
        invoke :help, ['config']
      else
        require_relative 'commands/config'
        StoryBranch::Commands::Config.new(options).execute
      end
    end
  end
end

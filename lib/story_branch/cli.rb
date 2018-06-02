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
    map %w[--version -v] => :version

    desc 'add', 'Add a new story branch configuration'
    method_option :help, aliases: '-h', type: :boolean,
                         desc: 'Display usage information'
    def add(*)
      if options[:help]
        invoke :help, ['add']
      else
        require_relative 'commands/add'
        StoryBranch::Commands::Add.new(options).execute
      end
    end

    desc 'migrate', 'Migrate old story branch configuration to the new format'
    method_option :help, aliases: '-h', type: :boolean,
                         desc: 'Display usage information'
    def migrate(*)
      if options[:help]
        invoke :help, ['migrate']
      else
        require_relative 'commands/migrate'
        StoryBranch::Commands::Migrate.new(options).execute
      end
    end

    desc 'config', 'Creates the initial config file'
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

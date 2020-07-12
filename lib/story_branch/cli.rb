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

    desc 'version', 'story_branch gem version'
    def version
      require_relative 'version'
      puts "v#{StoryBranch::VERSION}"
    end
    map %w[--version -v] => :version

    desc 'open_issue', 'Open ticket in the configured tracker'
    method_option :help, aliases: '-h', type: :boolean,
                         desc: 'Display usage information'
    def open_issue(*)
      if options[:help]
        invoke :help, ['open_issue']
      else
        require_relative 'commands/open_issue'
        StoryBranch::Commands::OpenIssue.new(options).execute
      end
    end

    desc 'unstart', 'Mark a started story as un-started [Only for Pivotal Tracker]'
    method_option :help, aliases: '-h', type: :boolean,
                         desc: 'Display usage information'
    def unstart(*)
      if options[:help]
        invoke :help, ['unstart']
      else
        require_relative 'commands/unstart'
        StoryBranch::Commands::Unstart.new(options).execute
      end
    end

    desc 'start', 'Mark an estimated story as started [Only for Pivotal Tracker]'
    method_option :help, aliases: '-h', type: :boolean,
                         desc: 'Display usage information'
    def start(*)
      if options[:help]
        invoke :help, ['start']
      else
        require_relative 'commands/start'
        StoryBranch::Commands::Start.new(options).execute
      end
    end

    desc 'finish',
         'Creates a commit message for the staged changes with the finish tag'
    method_option :help, aliases: '-h', type: :boolean,
                         desc: 'Display usage information'
    def finish(*)
      if options[:help]
        invoke :help, ['finish']
      else
        require_relative 'commands/finish'
        StoryBranch::Commands::Finish.new(options).execute
      end
    end

    desc 'create', 'Create branch from a ticket in the tracker'
    method_option :help, aliases: '-h', type: :boolean,
                         desc: 'Display usage information'
    def create(*)
      if options[:help]
        invoke :help, ['create']
      else
        require_relative 'commands/create'
        StoryBranch::Commands::Create.new(options).execute
      end
    end

    desc 'configure', 'Setup story branch with a new/existing project'
    method_option :help, aliases: '-h', type: :boolean,
                         desc: 'Display usage information'
    def configure(*)
      if options[:help]
        invoke :help, ['configure']
      else
        require_relative 'commands/configure'
        StoryBranch::Commands::Configure.new(options).execute
      end
    end
  end
end

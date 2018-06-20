# frozen_string_literal: true

require_relative '../config_manager'
require_relative '../command'
require 'tty-config'
require 'tty-prompt'

module StoryBranch
  module Commands
    # Command responsible for adding a new configuration to
    # the available configurations
    #
    # It will try to load the existing global story branch config
    # and then add the project id specified by the user.
    class Add < StoryBranch::Command
      def initialize(options)
        @options = options
        @config = ConfigManager.init_config(ENV['HOME'])
      end

      def execute(_input: $stdin, output: $stdout)
        create_global_config
        create_local_config
        output.puts 'Configuration added successfully'
      end

      private

      def create_local_config
        local_config = ConfigManager.init_config('.')
        local_config.set(:project_id, value: project_id)
        local_config.write
      end

      def create_global_config
        api_key = prompt.ask 'Please provide the api key:'
        @config.set(project_id, :api_key, value: api_key)
        @config.write(force: true)
      end

      def project_id
        return @project_id if @project_id
        @project_id = prompt.ask "Please provide this project's id:"
        @project_id
      end
    end
  end
end

# frozen_string_literal: true

require_relative '../command'
require 'tty-config'
require 'tty-prompt'

module StoryBranch
  module Commands
    class Add < StoryBranch::Command
      def initialize(options)
        @options = options
        @config = init_config
      end

      def execute(input: $stdin, output: $stdout)
        append_to_config
      end

      private

      def append_to_config
        prompt = ::TTY::Prompt.new
        project_name = prompt.ask "What should be this project's name?"
        api_key = prompt.ask 'Please provide the api key:'
        project_id = prompt.ask "Please provide this project's id:"
        @config.set(project_name, :api_key, value: api_key)
        @config.set(project_name, :project_id, value: project_id)
        @config.write(force: true)
      end

      # TODO: Move somewhere else as it is common across multiple commands
      def init_config
        config_file_path = Dir.home
        config_file_name = '.story_branch'
        config = ::TTY::Config.new
        config.filename = config_file_name
        config.append_path config_file_path
        config.read if config.persisted?
        config
      end

      def config_missing_message
        <<-MESSAGE
          Configuration file is missing.
          Trying to start a new project? Use story_branch add
          Migrating from old version? Use story_branch migrate
        MESSAGE
      end
    end
  end
end

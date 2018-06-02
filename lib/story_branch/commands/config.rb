# frozen_string_literal: true

require_relative '../command'
require 'tty-config'
require 'tty-prompt'

module StoryBranch
  module Commands
    class Config < StoryBranch::Command
      def initialize(options)
        @options = options
        @config = init_config
      end

      def execute(_input: $stdin, _output: $stdout)
        return if config_exist?
        prompt = ::TTY::Prompt.new
        project_name = prompt.ask "What should be this project's name?"
        api_key = prompt.ask 'Please provide the api key:'
        project_id = prompt.ask "Please provide this project's id:"
        @config.set(project_name, :api_key, value: api_key)
        @config.set(project_name, :project_id, value: project_id)
        @config.write
      end

      private

      def init_config
        config_file_path = Dir.home
        config_file_name = '.story_branch'
        config = ::TTY::Config.new
        config.filename = config_file_name
        config.append_path config_file_path
        config
      end

      def config_exist?
        return unless @config.persisted?
        puts config_exist_message
        true
      end

      def config_exist_message
        <<-MESSAGE
          Configuration file already exists.
          Trying to add a new project? Use story_branch add
          Migrating from old version? Use story_branch migrate
        MESSAGE
      end
    end
  end
end

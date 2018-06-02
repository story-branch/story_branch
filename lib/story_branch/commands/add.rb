# frozen_string_literal: true

require_relative '../command'
require 'tty-config'
require 'tty-prompt'

module StoryBranch
  module Commands
    class Add < StoryBranch::Command
      def initialize(options)
        @options = options
        @config = init_config(ENV['HOME'])
      end

      def execute(input: $stdin, output: $stdout)
        create_global_config
        create_local_config
        output.puts 'Configuration added successfully'
      end

      private

      def create_local_config
        local_config = init_config('.')
        local_config.set(:project_name, value: project_name)
        local_config.write
      end

      def create_global_config
        api_key = prompt.ask 'Please provide the api key:'
        project_id = prompt.ask "Please provide this project's id:"
        @config.set(project_name, :api_key, value: api_key)
        @config.set(project_name, :project_id, value: project_id)
        @config.write(force: true)
      end

      def project_name
        return @project_name if @project_name
        prompt = ::TTY::Prompt.new
        @project_name = prompt.ask "What should be this project's name?"
        @project_name
      end

      def init_config(path)
        config_file_path = path
        config_file_name = '.story_branch'
        config = ::TTY::Config.new
        config.filename = config_file_name
        config.append_path config_file_path
        config.read if config.persisted?
        config
      end
    end
  end
end

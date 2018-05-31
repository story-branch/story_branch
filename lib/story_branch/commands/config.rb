# frozen_string_literal: true

require_relative '../command'
require 'tty-config'
require 'tty-prompt'

module StoryBranch
  module Commands
    class Config < StoryBranch::Command
      def initialize(options)
        @options = options
        @config_file_path = Dir.home
        @config_file_name = '.story_branch'
      end

      def execute(output: $stdout, **)
        output.puts 'Looking for existing config file'
        if File.exist? "#{@config_file_path}/#{@config_file_name}.yml"
          output.puts 'Config file exists. Override?'
        else
          config = ::TTY::Config.new
          config.filename = @config_file_name
          config.append_path @config_file_path
          prompt = ::TTY::Prompt.new
          project_name = prompt.ask "What should be this project's name?"
          api_key = prompt.ask 'Please provide the api key:'
          project_id = prompt.ask "Please provide this project's id:"
          config.set(project_name, :api_key, value: api_key)
          config.set(project_name, :project_id, value: project_id)
          config.write
        end
      end
    end
  end
end

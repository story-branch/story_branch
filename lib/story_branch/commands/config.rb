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
        if File.exist? "#{@config_file_path}/#{@config_file_name}"
          output.puts 'Config file exists. Override?'
        else
          config = ::TTY::Config.new
          config.filename = @config_file_name
          config.append_path @config_file_path
          config.set('first_touch', :api_key, value: 'MAGICAPIKEY')
          config.set('first_touch', :project_id, value: '123456')
          config.write
        end
      end
    end
  end
end

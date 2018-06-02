# frozen_string_literal: true

require_relative '../command'
require 'tty-config'
require 'tty-prompt'
require 'yaml'
require 'fileutils'

module StoryBranch
  module Commands
    class Migrate < StoryBranch::Command
      CONFIG_FILE = "#{ENV['HOME']}/.story_branch"

      def initialize(options)
        @options = options
        @config = nil
        @old_config = nil
        @project_name = nil
      end

      def execute(_input: $stdin, _output: $stdout)
        return unless old_config_exists?
        @config = init_config
        return if config_exist?
        migrate_key('api', 'PIVOTAL_API_KEY', :api_key)
        migrate_key('project_id', 'PIVOTAL_PROJECT_ID', :project_id)
        @config.write
        FileUtils.rm CONFIG_FILE
        puts 'Migration complete'
      end

      private

      # TODO: Move this somewhere else as it is the same as config command
      def config_exist?
        return unless @config.persisted?
        puts config_exist_message
        true
      end

      def config_exist_message
        <<-MESSAGE
          Configuration file already exists. Have you migrated already?
          Trying to add a new project? Use story_branch add
        MESSAGE
      end

      def migrate_key(old_key, env, new_key)
        value = config_value(old_key, env)
        if value.nil?
          puts cant_migrate_missing_value
          exit 1
        end
        @config.set(project_name, new_key, value: value)
      end

      def project_name
        return @project_name if @project_name
        prompt = ::TTY::Prompt.new
        @project_name = prompt.ask "What should be this project's name?"
        @project_name
      end

      # TODO: Probably makes sense to move this to a common tty config
      # utils file kind of thing as it will be shared by some commands.
      def init_config
        config_file_path = Dir.home
        config_file_name = '.story_branch'
        config = ::TTY::Config.new
        config.filename = config_file_name
        config.append_path config_file_path
        config
      end

      def old_config_exists?
        return true if File.exist? CONFIG_FILE
        puts old_config_file_not_found
        false
      end

      def old_config_file_not_found
        <<-MESSAGE
          Old configuration file not found in #{CONFIG_FILE}
          Trying to start from scratch? Use story_branch config
        MESSAGE
      end

      def cant_migrate_missing_value
        <<-MESSAGE
          Old configuration file not found in #{CONFIG_FILE}
          Trying to start from scratch? Use story_branch config
        MESSAGE
      end

      def config_value(key, env)
        @old_config ||= ::YAML.load_file CONFIG_FILE
        return @old_config[key] if @old_config[key]
        ENV[env]
      end
    end
  end
end

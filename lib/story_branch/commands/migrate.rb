# frozen_string_literal: true

require_relative '../command'
require 'tty-config'
require 'tty-prompt'
require 'yaml'
require 'fileutils'

module StoryBranch
  module Commands
    class Migrate < StoryBranch::Command
      GLOBAL_CONFIG_FILE = "#{Dir.home}/.story_branch".freeze
      LOCAL_CONFIG_FILE = '.story_branch'.freeze
      OLD_CONFIG_FILES = [LOCAL_CONFIG_FILE, GLOBAL_CONFIG_FILE].freeze

      # TODO: Think how to migrate multiple configured projects locally
      # Scenario:
      # - ENV var/home config file with api key
      # - project directory with project id

      def initialize(options)
        @options = options
        @config = nil
        @project_name = nil
      end

      def execute(_input: $stdin, output: $stdout)
        if missing_old_config?
          error_migrating(output, old_config_file_not_found)
          return
        end

        @config = init_config(Dir.home)
        # return if config_exist?
        unless migrate_key('api', 'PIVOTAL_API_KEY', :api_key)
          error_migrating(output, cant_migrate_missing_value)
          return
        end
        unless migrate_key('project', 'PIVOTAL_PROJECT_ID', :project_id)
          error_migrating(output, cant_migrate_missing_value)
          return
        end
        @config.write
        create_local_config
        clean_old_config_files
        output.puts 'Migration complete'
      end

      private

      def error_migrating(output, error_message)
        output.puts error_message
      end

      def missing_old_config?
        OLD_CONFIG_FILES.each { |file| return false if File.exist?(file) }
        return false if env_set?
        true
      end

      def env_set?
        ENV['PIVOTAL_API_KEY'].length.positive? ||
          ENV['PIVOTAL_PROJECT_ID'].length.positive?
      end

      def migrate_keys
        migrate_key('api', 'PIVOTAL_API_KEY', :api_key)
        migrate_key('project_id', 'PIVOTAL_PROJECT_ID', :project_id)
        @config.write
      end

      def migrate_key(old_key, env, new_key)
        value = config_value(old_key, env)
        return false if value.nil?
        @config.set(project_name, new_key, value: value.to_s)
      end

      def config_value(key, env)
        OLD_CONFIG_FILES.each do |config_file|
          if File.exist? config_file
            old_config = YAML.load_file config_file
            return old_config[key] if old_config && old_config[key]
          end
        end
        ENV[env]
      end

      def create_local_config
        local_config = init_config('.')
        local_config.set(:project_name, value: project_name)
        local_config.write
      end

      def clean_old_config_files
        [GLOBAL_CONFIG_FILE, LOCAL_CONFIG_FILE].each do |file|
          FileUtils.rm file if File.exist? file
        end
      end

  #     # TODO: Move this somewhere else as it is the same as config command
  #     def config_exist?
  #       return unless @config.persisted?
  #       puts config_exist_message
  #       true
  #     end

  #     def config_exist_message
  #       <<-MESSAGE
  #         Configuration file already exists. Have you migrated already?
  #         Trying to add a new project? Use story_branch add
  #       MESSAGE
  #     end

      def project_name
        return @project_name if @project_name
        prompt = ::TTY::Prompt.new
        @project_name = prompt.ask "What should be this project's name?"
        @project_name
      end

      # TODO: Probably makes sense to move this to a common tty config
      # utils file kind of thing as it will be shared by some commands.
      def init_config(path)
        config = ::TTY::Config.new
        config.filename = '.story_branch'
        config.append_path path
        config
      end

      def old_config_file_not_found
        <<-MESSAGE
Old configuration not found.
Trying to start from scratch? Use story_branch add
        MESSAGE
      end

      def cant_migrate_missing_value
        <<-MESSAGE
          Old configuration not found. Nothing has been migrated
          Trying to start from scratch? Use story_branch add
        MESSAGE
      end
    end
  end
end

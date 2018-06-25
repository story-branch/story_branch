# frozen_string_literal: true

require_relative '../config_manager'
require_relative '../command'
require 'yaml'
require 'fileutils'

module StoryBranch
  module Commands
    # Migrate command is intended to make the migration from old version
    # of story branch to the latest one easier.
    class Migrate < StoryBranch::Command
      GLOBAL_CONFIG_FILE = "#{Dir.home}/.story_branch"
      LOCAL_CONFIG_FILE = '.story_branch'
      OLD_CONFIG_FILES = [LOCAL_CONFIG_FILE, GLOBAL_CONFIG_FILE].freeze

      def initialize(options)
        @options = options
        @config = ConfigManager.init_config(Dir.home)
      end

      def execute(_input: $stdin, output: $stdout)
        if missing_old_config?
          error_migrating(output, old_config_file_not_found)
          return
        end
        @config.set(project_id, :api_key, value: api_key)
        @config.write(force: true)
        create_local_config
        clean_old_config_files
        output.puts 'Migration complete'
      end

      private

      def project_id
        return @project_id if @project_id
        @project_id = old_config_value('project', 'PIVOTAL_PROJECT_ID')
        @project_id
      end

      def api_key
        return @api_key if @api_key
        @api_key = old_config_value('api', 'PIVOTAL_API_KEY')
        @api_key
      end

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

      def old_config_value(key, env)
        OLD_CONFIG_FILES.each do |config_file|
          if File.exist? config_file
            old_config = YAML.load_file config_file
            return old_config[key].to_s if old_config && old_config[key]
          end
        end
        ENV[env]
      end

      def create_local_config
        local_config = ConfigManager.init_config('.')
        local_config.set(:project_id, value: project_id)
        local_config.write
      end

      def clean_old_config_files
        [GLOBAL_CONFIG_FILE, LOCAL_CONFIG_FILE].each do |file|
          FileUtils.rm file if File.exist? file
        end
      end

      def old_config_file_not_found
        <<~MESSAGE
          Old configuration not found.
          Trying to start from scratch? Use story_branch add
        MESSAGE
      end

      def cant_migrate_missing_value
        <<~MESSAGE
          Old configuration not found. Nothing has been migrated
          Trying to start from scratch? Use story_branch add
        MESSAGE
      end
    end
  end
end

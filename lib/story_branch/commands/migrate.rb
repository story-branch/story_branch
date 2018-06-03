# frozen_string_literal: true

require_relative '../command'
require 'tty-config'
require 'tty-prompt'
require 'yaml'
require 'fileutils'

module StoryBranch
  module Commands
    class Migrate < StoryBranch::Command
      GLOBAL_CONFIG_FILE = "#{ENV['HOME']}/.story_branch".freeze
      LOCAL_CONFIG_FILE = '.story_branch'.freeze
      OLD_CONFIG_FILES = [LOCAL_CONFIG_FILE, GLOBAL_CONFIG_FILE].freeze

      def initialize(options)
        @options = options
        @config = nil
        @old_config = nil
        @project_name = nil
      end

      def execute(_input: $stdin, output: $stdout)
        if missing_old_config?
          output.puts old_config_file_not_found
          return
        end
        # return unless old_config_exists?
        # @config = init_config(ENV['HOME'])
        # return if config_exist?
        # migrate_keys
        # create_local_config
        # clean_old_config_files
        # output.puts 'Migration complete'
      end

      private

      def missing_old_config?
        OLD_CONFIG_FILES.each { |file| return false if File.exist?(file) }
        return false if env_set?
        true
      end

      def env_set?
        ENV['PIVOTAL_API_KEY'].length.positive? ||
          ENV['PIVOTAL_PROJECT_ID'].length.positive?
      end

  #     def clean_old_config_files
  #       [GLOBAL_CONFIG_FILE, LOCAL_CONFIG_FILE].each do |file|
  #         FileUtils.rm file
  #       end
  #     end

  #     def migrate_keys
  #       migrate_key('api', 'PIVOTAL_API_KEY', :api_key)
  #       migrate_key('project_id', 'PIVOTAL_PROJECT_ID', :project_id)
  #       @config.write
  #     end

  #     def create_local_config
  #       local_config = init_config('.')
  #       local_config.set(:project_name, project_name)
  #       local_config.write
  #     end

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

  #     def migrate_key(old_key, env, new_key)
  #       value = config_value(old_key, env)
  #       if value.nil?
  #         puts cant_migrate_missing_value
  #         exit 1
  #       end
  #       @config.set(project_name, new_key, value: value)
  #     end

  #     def project_name
  #       return @project_name if @project_name
  #       prompt = ::TTY::Prompt.new
  #       @project_name = prompt.ask "What should be this project's name?"
  #       @project_name
  #     end

  #     # TODO: Probably makes sense to move this to a common tty config
  #     # utils file kind of thing as it will be shared by some commands.
  #     def init_config(path)
  #       config_file_path = path
  #       config_file_name = '.story_branch'
  #       config = ::TTY::Config.new
  #       config.filename = config_file_name
  #       config.append_path config_file_path
  #       config
  #     end

  #     def old_config_exists?
  #       return true if File.exist? GLOBAL_CONFIG_FILE
  #       puts old_config_file_not_found
  #       false
  #     end

      def old_config_file_not_found
        <<-MESSAGE
Old configuration not found.
Trying to start from scratch? Use story_branch add
        MESSAGE
      end

  #     def cant_migrate_missing_value
  #       <<-MESSAGE
  #         Old configuration file not found in #{GLOBAL_CONFIG_FILE}
  #         Trying to start from scratch? Use story_branch add
  #       MESSAGE
  #     end

  #     def config_value(key, env)
  #       @old_config ||= ::YAML.load_file GLOBAL_CONFIG_FILE
  #       return @old_config[key] if @old_config[key]
  #       ENV[env]
  #     end
    end
  end
end

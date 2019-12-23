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
        @config = ConfigManager.init_config(Dir.home)
        @local_config = ConfigManager.init_config('.')
      end

      def execute(_input: $stdin, output: $stdout)
        create_local_config
        create_global_config
        output.puts 'Configuration added successfully'
      end

      private

      def create_local_config
        return if local_config_has_value?

        puts "Setting #{tracker}"
        @local_config.set(:tracker, value: tracker)

        puts "Appending #{project_id}"
        @local_config.append(project_id, to: :project_id)

        @local_config.write(force: true)
      end

      def create_global_config
        api_key = prompt.ask('Please provide the api key:', required: true)
        @config.set(project_id, :api_key, value: api_key)
        @config.write(force: true)

        return unless tracker == 'jira'

        # rubocop:disable Layout/LineLength
        username = prompt.ask('Please provide username (email most of the times) for this key:',
                              required: true)
        # rubocop:enable Layout/LineLength
        @config.set(project_id, :username, value: username)
        @config.write(force: true)
      end

      def project_id
        return @project_id if @project_id

        if tracker == 'jira'
          # rubocop:disable Layout/LineLength
          project_domain = prompt.ask("What is your JIRA's subdomain?", required: true)
          project_key = prompt.ask("What is your JIRA's project key?", required: true)
          # rubocop:enable Layout/LineLength
          @project_id = "#{project_domain}|#{project_key}"
        else
          # rubocop:disable Layout/LineLength
          @project_id = prompt.ask("Please provide this project's id:", required: true)
          # rubocop:enable Layout/LineLength
        end
      end

      def tracker
        return @tracker if @tracker

        trackers = {
          'Pivotal Tracker' => 'pivotal-tracker',
          'Github' => 'github',
          'JIRA' => 'jira'
        }
        @tracker = prompt.select('Which tracker are you using?', trackers)
      end

      def local_config_has_value?
        config_value = @local_config.fetch(:project_id)
        if config_value.is_a? Array
          config_value.include?(project_id)
        else
          config_value == project_id
        end
      end
    end
  end
end

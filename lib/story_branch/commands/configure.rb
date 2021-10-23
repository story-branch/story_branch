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
    class Configure < StoryBranch::Command
      def initialize(_options)
        super()
        @new_config = ConfigManager.new
      end

      def execute(_input: $stdin, output: $stdout)
        set_tracker_type
        set_project_key
        create_global_config
        @new_config.save
        output.puts 'Configuration added successfully'
      end

      private

      def set_tracker_type
        return if @new_config.contains?(project_key)

        puts "Setting #{tracker}"
        @new_config.tracker_type = tracker
      end

      def set_project_key
        puts "Setting #{project_key}"
        @new_config.project_key = project_key
      end

      def create_global_config
        api_key = prompt.ask('Please provide the api key:', required: true)
        @new_config.api_key = api_key

        return unless tracker == 'jira'

        username = prompt.ask('Please provide username (email most of the times) for this key:',
                              required: true)
        @new_config.username = username
      end

      def project_key
        return @project_key if @project_key

        @project_key = ask_for_project_key
      end

      def ask_for_project_key
        if tracker == 'jira'
          project_domain = prompt.ask("What is your JIRA's subdomain?",
                                      required: true)
          project_key = prompt.ask("What is your JIRA's project key?",
                                   required: true)

          "#{project_domain}|#{project_key}"
        else
          prompt.ask("Please provide this project's id:", required: true)
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
    end
  end
end

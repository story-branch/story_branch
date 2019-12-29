# frozen_string_literal: true

require 'tty-config'
require 'tty-prompt'

module StoryBranch
  # Config manager is used to manage all possible configuration settings
  # it uses mainly TTY::Config with the configuration file name set
  class ConfigManager
    CONFIG_FILENAME = '.story_branch'

    attr_reader :errors

    def initialize
      @prompt = TTY::Prompt.new(interrupt: :exit)
      @errors = []
    end

    def local_config
      # TODO: For XDG config this should use something else as the path?
      @local_config ||= init_config('.')
    end

    def global_config
      # TODO: For XDG config this should use something else as the path?
      @global_config ||= init_config(Dir.home)
    end

    def api_key
      @api_key ||= global_config.fetch(project_id, :api_key)
    end

    def username
      @username ||= global_config.fetch(project_id, :username)
    end

    def finish_tag
      return @finish_tag if @finish_tag

      fallback = @global_config.fetch(project_id,
                                      :finish_tag,
                                      default: 'Finishes')
      @finish_tag = @local_config.fetch(:finish_tag, default: fallback)
      @finish_tag
    end

    def issue_placement
      return @issue_placement if @issue_placement

      fallback = @global_config.fetch(project_id,
                                      :issue_placement,
                                      default: 'End')
      @issue_placement = @local_config.fetch(:issue_placement,
                                             default: fallback)
      @issue_placement
    end

    def project_id
      return @project_id if @project_id

      project_ids = @local_config.fetch(:project_id)
      @project_id = choose_project_id(project_ids)
    end

    def choose_project_id(project_ids)
      return project_ids unless project_ids.is_a? Array
      return project_ids[0] unless project_ids.length > 1

      @prompt.select('Which project you want to fetch from?', project_ids)
    end

    def tracker
      @local_config.fetch(:tracker, default: 'pivotal-tracker')
    end

    def valid?
      validate
      @errors.length.positive?
    end

    private

    def validate
      @errors << 'Project ID is not set' if project_id.nil?
    end

    def init_config(path)
      config = ::TTY::Config.new
      config.filename = CONFIG_FILENAME
      config.append_path path
      config.read if config.persisted?
      config
    end
  end
end

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
      @config = load_config
      @errors = []
    end

    def tracker_type
      @config.fetch(:tracker, default: 'pivotal-tracker')
    end

    def tracker_params
      {
        tracker_domain: tracker_domain,
        username: username,
        project_id: project_id,
        api_key: api_key
      }
    end

    def valid?
      validate
      @errors.length.zero?
    end

    private

    def api_key
      @api_key ||= @config.fetch(project_key, :api_key)
    end

    def username
      @username ||= @config.fetch(project_key, :username)
    end

    def finish_tag
      @finish_tag ||= @config.fetch(project_key, :finish_tag, default: 'Finishes')
    end

    def issue_placement
      @issue_placement ||= @config.fetch(:issue_placement, default: 'End')
    end

    def project_key
      return @project_key if @project_key

      project_keys = @config.fetch(:project_id)

      @project_key = choose_project_id(project_keys)
    end

    def project_id
      return @project_id if @project_id

      @project_id = if tracker_type == 'jira'
                      project_key.split('|')[1]
                    else
                      project_key
                    end
    end

    def tracker_domain
      return @tracker_domain if @tracker_domain

      @tracker_domain = if tracker_type != 'jira'
                          ''
                        else
                          project_key.split('|')[0]
                        end
    end

    def choose_project_id(project_ids)
      return project_ids unless project_ids.is_a? Array
      return project_ids[0] unless project_ids.length > 1

      @prompt.select('Which project you want to fetch from?', project_ids)
    end

    def validate
      @errors << 'Project ID is not set' if project_id.nil?
    end

    def load_config
      local = init_config('.')
      global = init_config(Dir.home)
      local.merge(global)
      binding.pry

      local
    end

    def init_config(path)
      config = ::TTY::Config.new
      config.filename = CONFIG_FILENAME
      config.append_path path
      config.read
      config
    end
  end
end

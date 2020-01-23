# frozen_string_literal: true

require 'tty-config'
require 'tty-prompt'
require 'xdg'

module StoryBranch
  # Config manager is used to manage all possible configuration settings
  # it uses mainly TTY::Config with the configuration file name set
  class ConfigManager
    CONFIG_FILENAME = '.story_branch'

    attr_reader :errors

    def initialize
      @prompt = TTY::Prompt.new(interrupt: :exit)
      load_configs
      @config = ::TTY::Config.new
      @config.merge(@local)
      @config.merge(@global)
      @errors = []
    end

    def tracker_type
      @tracker_type ||= @config.fetch(:tracker, default: 'pivotal-tracker')
    end

    def tracker_type=(tracker)
      @local.set(:tracker, value: tracker)
    end

    def issue_placement
      @issue_placement ||= @config.fetch(:issue_placement, default: 'End')
    end

    def finish_tag
      @finish_tag ||= @config.fetch(project_key,
                                    :finish_tag, default: 'Finishes')
    end

    def project_key=(key)
      @project_key = key
      @local.append(key, to: :project_id) unless contains?(key)
    end

    def api_key=(key)
      @api_key = key
      @global.set(@project_key, :api_key, value: key)
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

    def contains?(project_key)
      project_keys = @config.fetch(:project_id)
      if project_keys.is_a? Array
        project_keys.include?(project_key)
      else
        project_keys == project_key
      end
    end

    def save
      @local.write(force: true)
      @global.write(force: true)
    end

    private

    def api_key
      @api_key ||= @config.fetch(project_key, :api_key)
    end

    def username
      @username ||= @config.fetch(project_key, :username)
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

    def load_configs
      @local = read_config('.')
      xdg_conf = XDG::Config.new
      home_path = if conf_exist?(Dir.home)
                    Dir.home
                  else
                    xdg_conf.home
                  end
      @global = read_config(home_path)
    end

    def read_config(path)
      config = init_config(path)
      config.read if config.persisted?
      config
    end

    def conf_exist?(path)
      config = init_config(path)
      config.persisted?
    end

    def init_config(path)
      config = ::TTY::Config.new
      config.filename = CONFIG_FILENAME
      config.append_path path
      config
    end
  end
end

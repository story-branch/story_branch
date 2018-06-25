# frozen_string_literal: true

require 'tty-config'

module StoryBranch
  # Config manager class is simply a wrapper around
  # TTY::Config with the configuration file name set
  # so we DRY our code.
  class ConfigManager
    # TODO: Might be worht moving the configuration filename
    # to a constant
    def self.init_config(path, should_read = true)
      config = ::TTY::Config.new
      config.filename = '.story_branch'
      config.append_path path
      config.read if config.persisted? && should_read
      config
    end
  end
end

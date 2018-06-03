require 'tty-config'

module StoryBranch
  class ConfigManager
    def self.init_config(path, should_read = true)
      config = ::TTY::Config.new
      config.filename = '.story_branch'
      config.append_path path
      config.read if config.persisted? && should_read
      config
    end
  end
end

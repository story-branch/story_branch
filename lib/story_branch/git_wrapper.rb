# frozen_string_literal: true

# NOTE: Consider extracting this to a separate gem
module StoryBranch
  # GitWrapper to help running git commands with direct system calls
  class GitWrapper
    def self.command(cmd, opts = [])
      gw = new
      gw.call(cmd, opts)
    end

    def self.command_lines(cmd, opts = [])
      result = command(cmd, opts)
      lines = result.split("\n")
      lines.each(&:strip!)
    end

    def initialize
      @system_git = 'git'
    end

    def call(cmd, opts = [])
      opts = prepare_opts(opts)
      git_cmd = "#{@system_git} #{cmd} #{opts}"
      `#{git_cmd}`.chomp.strip
    end

    private

    # NOTE: Taken from ruby git gem
    def escape(str = '')
      str = str.to_s
      return "'#{str.gsub('\'', '\'"\'"\'')}'" if RUBY_PLATFORM !~ /mingw|mswin/

      # Keeping the old escape format for windows users
      escaped = str.gsub('\'', '\'\\\'\'')
      %("#{escaped}")
    end

    def prepare_opts(opts = [])
      [opts].flatten.map { |s| escape(s) }.join(' ')
    end
  end
end

# StoryBranch::GitWrapper.command()
# StoryBranch::GitWrapper.command_lines()

# require_relative './lib/story_branch/git_wrapper.rb'
# StoryBranch::GitWrapper.command('branch', '-a')
# StoryBranch::GitWrapper.command_lines('branch', '-a')

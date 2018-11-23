# frozen_string_literal: true

# NOTE: Consider extracting this to a separate gem
module StoryBranch
  # GitWrapper to help running git commands with direct system calls
  # Essentially it provides a couple of commands to interact with git
  # - StoryBranch::GitWrapper.command('<cmd>', [<opts>])
  #   Returns the output as is
  #
  # - StoryBranch::GitWrapper.command_lines('<cmd>', [<opts>])
  #   Returns the output split into an array of lines, stripped and chomped
  #
  # - StoryBranch::GitWrapper.branch_names
  #   Returns the list of available branch names, locally and configured remotes
  class GitWrapper
    STATI_MATCHERS = {
      modified_rx: /^ M (.*)/,
      untracked_rx: /^\?\? (.*)/,
      staged_rx: /^M  (.*)/,
      added_rx: /^A  (.*)/
    }.freeze

    def self.command(cmd, opts = [])
      gw = new
      gw.call(cmd, opts)
    end

    def self.command_lines(cmd, opts = [])
      result = command(cmd, opts)
      lines = result.split("\n")
      lines.each(&:strip!)
    end

    def self.branch_names
      # NOTE: Regex matcher for cases as:
      # remotes/origin/allow.... <- remote branch (remove 'remotes/origin')
      # * allow.... <- * indicates current branch (remove '* ')
      # allow <- local branch (do nothing)
      regex = %r{(^remotes\/.*\/|\s|[*])}
      all_branches.map do |line|
        line = line.sub(regex, '')
        line
      end
    end

    def self.current_branch
      current_branch_line = all_branches.detect do |line|
        line.match(/\*/)
      end
      current_branch_line.tr('*', ' ')
    end

    def self.all_branches
      command_lines('branch', '-a')
    end

    def self.create_branch(name)
      command('checkout', ['-b', name])
    end

    def self.status
      g_status = command_lines('status', '-s')
      return nil if g_status.empty?

      {
        modified: status_collect(g_status, STATI_MATCHERS[:modified_rx]),
        untracked: status_collect(g_status, STATI_MATCHERS[:untracked_rx]),
        added: status_collect(g_status, STATI_MATCHERS[:added_rx]),
        staged: status_collect(g_status, STATI_MATCHERS[:staged_rx])
      }
    end

    def self.status_collect(status, regex)
      chosen_stati = status.select { |e| e.match(regex) }
      chosen_stati.map { |e| e.match(regex)[1] }
    end

    def self.commit(message)
      command('commit', ['-m', message])
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

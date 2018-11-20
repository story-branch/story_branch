# frozen_string_literal: true

require 'levenshtein'

module StoryBranch
  # Class used to interact with git. It relies on git gem as the wrapper
  # and levenshtein algo to determine branch name proximity
  class GitUtils
    def self.existing_branch?(name)
      branch_names.each do |n|
        return true if Levenshtein.distance(n, name) < 3

        branch_name_match = n.match(/(.*)(-[1-9][0-9]+$)/)
        next unless branch_name_match

        levenshtein_distance = Levenshtein.distance branch_name_match[1], name
        return true if levenshtein_distance < 3
      end
      false
    end

    def self.branch_for_story_exists?(id)
      branch_names.each do |n|
        branch_id = n.match(/-[1-9][0-9]+$/)
        next unless branch_id
        return true if branch_id.to_s == "-#{id}"
      end
      false
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
      current_branch_line.tr('*', ' ').strip
    end

    def self.all_branches
      `git branch -a`.split("\n")
    end

    def self.current_story
      /(.*)-(\d+$)/.match current_branch
    end

    def self.current_branch_story_parts
      matches = current_story
      return {} unless matches.length == 3

      { title: matches[1], id: matches[2].to_i }
    end

    def self.create_branch(name)
      `git checkout -b #{name}`
    end

    def self.status_collect(status, regex)
      chosen_stati = status.select { |e| e.match(regex) }
      chosen_stati.map { |e| e.match(regex)[1] }
    end

    def self.status
      modified_rx  = /^ M (.*)/
      untracked_rx = /^\?\? (.*)/
      staged_rx    = /^M  (.*)/
      added_rx     = /^A  (.*)/
      status = `git status -s`.split("\n")
      return nil if status.empty?

      {
        modified: status_collect(status, modified_rx),
        untracked: status_collect(status, untracked_rx),
        added: status_collect(status, added_rx),
        staged: status_collect(status, staged_rx)
      }
    end

    def self.status?(state)
      return false unless status

      !status[state].empty?
    end

    def self.commit(message)
      `git commit -m \"#{message}\"`
    end
  end
end

# frozen_string_literal: true

require 'git'
require 'levenshtein'

module StoryBranch
  # Class used to interact with git. It relies on git gem as the wrapper
  # and levenshtein algo to determine branch name proximity
  class GitUtils
    def self.g
      ::Git.open '.'
    end

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

    def self.existing_story?(id)
      branch_names.each do |n|
        branch_id = n.match(/-[1-9][0-9]+$/)
        next unless branch_id
        return true if branch_id.to_s == "-#{id}"
      end
      false
    end

    def self.branch_names
      g.branches.map(&:name)
    end

    def self.current_branch
      g.current_branch
    end

    def self.current_story
      current_branch.match(/(.*)-(\d+$)/)
    end

    def self.current_branch_story_parts
      matches = current_story
      return unless matches.length == 3
      { title: matches[1], id: matches[2] }
    end

    def self.create_branch(name)
      g.branch(name).create
      g.branch(name).checkout
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
      status = g.lib.send(:command, 'status', '-s').lines
      return nil if status.empty?
      {
        modified:  status_collect(status, modified_rx),
        untracked: status_collect(status, untracked_rx),
        added:     status_collect(status, added_rx),
        staged:    status_collect(status, staged_rx)
      }
    end

    def self.status?(state)
      return false unless status
      !status[state].empty?
    end

    def self.commit(message)
      g.commit(message)
    end
  end
end

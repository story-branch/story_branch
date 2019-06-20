# frozen_string_literal: true

require 'damerau-levenshtein'
require_relative './git_wrapper'

module StoryBranch
  # Class used to interact with git. It relies on git gem as the wrapper
  # and levenshtein algo to determine branch name proximity
  class GitUtils
    def self.existing_branch?(name)
      GitWrapper.branch_names.each do |n|
        return true if DamerauLevenshtein.distance(n, name) < 3

        branch_name_match = n.match(/(.*)(-[1-9]+[0-9]*$)/)
        next unless branch_name_match

        distance = DamerauLevenshtein.distance branch_name_match[1], name
        return true if distance < 3
      end
      false
    end

    def self.branch_for_story_exists?(id)
      GitWrapper.branch_names.each do |n|
        branch_id = n.match(/-[1-9]+[0-9]*$/)
        next unless branch_id
        return true if branch_id.to_s == "-#{id}"
      end
      false
    end

    def self.current_story
      /(.*)-(\d+$)/.match GitWrapper.current_branch
    end

    def self.current_branch_story_parts
      matches = current_story
      return {} unless matches.length == 3

      title = matches[1].tr('-', ' ').strip
      { title: title, id: matches[2].to_i }
    end

    def self.status?(state)
      status = GitWrapper.status
      return false unless status

      !status[state].empty?
    end
  end
end

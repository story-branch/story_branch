# frozen_string_literal: true

require 'damerau-levenshtein'
require 'story_branch/git_wrapper'

module StoryBranch
  # Class used to interact with git. It relies on git gem as the wrapper
  # and levenshtein algo to determine branch name proximity
  class GitUtils
    def self.similar_branch?(name)
      Git::Wrapper.branch_names.each do |n|
        return true if DamerauLevenshtein.distance(n, name) < 3

        branch_name_match = n.match(/(.*)(-[1-9]+[0-9]*$)/)
        next unless branch_name_match

        distance = DamerauLevenshtein.distance branch_name_match[1], name
        return true if distance < 3
      end
      false
    end

    def self.branch_to_story_string(regex_matcher = /.*-(\d+$)/)
      Git::Wrapper.current_branch.match(regex_matcher)
    end

    def self.status?(state)
      status = Git::Wrapper.status
      return false unless status

      !status[state].empty?
    end
  end
end

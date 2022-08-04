# frozen_string_literal: true

module StoryBranch
  class IssueBase
    attr_reader :title, :id, :html_url

    def initialize(tracker_issue, project = nil)
      @project = project
      @story = tracker_issue
    end

    def to_s
      "#{@id} - #{@title}"
    end

    def dashed_title
      StoryBranch::StringUtils.normalised_branch_name @title
    end
  end
end

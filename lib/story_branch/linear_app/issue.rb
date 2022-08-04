# frozen_string_literal: true

require_relative '../issue_base'

module StoryBranch
  module LinearApp
    # LinearApp Issue representation
    class Issue < StoryBranch::IssueBase
      # NOTE: project here represents the team_id only
      def initialize(tracker_issue, project)
        super
        @title = tracker_issue['title']
        @id = "#{@project}-#{tracker_issue['number']}"
        @html_url = tracker_issue['url']
      end
    end
  end
end

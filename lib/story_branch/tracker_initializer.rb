# frozen_string_literal: true

require_relative './pivotal/tracker'
require_relative './github/tracker'
require_relative './jira/tracker'
require_relative './linear_app/tracker'

module StoryBranch
  class TrackerInitializer
    AVAILABLE_TRACKERS = {
      'pivotal-tracker' => StoryBranch::Pivotal::Tracker,
      'github' => StoryBranch::Github::Tracker,
      'jira' => StoryBranch::Jira::Tracker,
      'linearapp' => StoryBranch::LinearApp::Tracker
    }.freeze

    def self.initialize_tracker(config:)
      tracker_class = AVAILABLE_TRACKERS[config.tracker_type]
      raise 'Invalid tracker configuration' unless tracker_class

      tracker_class.new(**config.tracker_params)
    end
  end
end

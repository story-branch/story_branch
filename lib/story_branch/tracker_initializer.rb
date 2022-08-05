# frozen_string_literal: true

require_relative './constants'
require_relative './pivotal/tracker'
require_relative './github/tracker'
require_relative './jira/tracker'
require_relative './linear_app/tracker'

module StoryBranch
  class TrackerInitializer
    def self.initialize_tracker(config:)
      tracker_class = find_tracker_class(config.tracker_type)
      raise 'Invalid tracker configuration' unless tracker_class

      tracker_class.new(**config.tracker_params)
    end

    def self.find_tracker_class(tracker_type)
      tracker_str = StoryBranch::TRACKERS_CLASSES[tracker_type]
      return nil unless tracker_str

      Kernel.const_get(tracker_str)
    end
  end
end

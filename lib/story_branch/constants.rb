# frozen_string_literal: true

module StoryBranch
  AVAILABLE_TRACKERS = {
    'Pivotal Tracker' => 'pivotal-tracker',
    'Github' => 'github',
    'JIRA' => 'jira',
    'LinearApp' => 'linearapp'
  }.freeze

  TRACKERS_CLASSES = {
    'pivotal-tracker' => 'StoryBranch::Pivotal::Tracker',
    'github' => 'StoryBranch::Github::Tracker',
    'jira' => 'StoryBranch::Jira::Tracker',
    'linearapp' => 'StoryBranch::LinearApp::Tracker'
  }.freeze
end

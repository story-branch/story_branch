# frozen_string_literal: true

require 'story_branch'

RSpec.describe StoryBranch do
  it 'has a version number' do
    expect(StoryBranch::VERSION).not_to be nil
  end
end

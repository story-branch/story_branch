# frozen_string_literal: true

require 'spec_helper'
require 'story_branch/git_utils'

RSpec.describe StoryBranch::GitUtils do
  describe 'g' do
    before do
      allow(::Git).to receive(:open)
    end

    it 'uses Git gem to open the local git directory' do
      StoryBranch::GitUtils.g
      expect(Git).to have_received(:open).with('.')
    end
  end
end

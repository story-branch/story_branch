# frozen_string_literal: true

require 'spec_helper'
require 'story_branch/git_utils'
require 'story_branch/git_wrapper'

RSpec.describe StoryBranch::GitUtils do
  let(:distance1) { 3 }
  let(:distance2) { 4 }

  before do
    allow(StoryBranch::GitWrapper).to receive(:branch_names).and_return(branches)
    allow(Levenshtein).to receive(:distance).and_return(distance1, distance2)
  end

  describe 'existing_branch?' do
    let(:branches) { %w[amazing-name-1 amazing-feature-2] }

    it 'determnines levenshtein distance between branch name and branch list' do
      StoryBranch::GitUtils.existing_branch?('new-branch-name')
      expect(Levenshtein).to have_received(:distance)
    end

    describe 'when levenshtein distance is not close' do
      it 'determnines levenshtein distance between branch name and branch list' do
        StoryBranch::GitUtils.existing_branch?('new-branch-name')
        # TODO:
        # Check it has been called - with branches and branch name
        expect(Levenshtein).to have_received(:distance)
      end

      it 'returns false' do
        expect(StoryBranch::GitUtils.existing_branch?('new-branch')).to eq false
      end
    end

    describe 'when levenshtein distance is close' do
      it 'returns false' do
        expect(StoryBranch::GitUtils.existing_branch?('new-branch')).to eq false
      end
    end
  end

  describe 'branch_for_story_exists?' do
    let(:branches) { %w[amazing-name-1 amazing-feature-2] }

    describe 'existing branches include the passed id' do
      it 'fetches all branches with command execution' do
        StoryBranch::GitUtils.branch_for_story_exists?(1)
        expect(StoryBranch::GitWrapper).to have_received(:branch_names)
      end

      it 'returns true' do
        expect(StoryBranch::GitUtils.branch_for_story_exists?(1)).to eq true
      end
    end

    describe 'existing branches does not include the passed id' do
      it 'returns false' do
        expect(StoryBranch::GitUtils.branch_for_story_exists?(3)).to eq false
      end
    end
  end
end

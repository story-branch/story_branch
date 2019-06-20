# frozen_string_literal: true

require 'spec_helper'
require 'story_branch/git_utils'
require 'story_branch/git_wrapper'

# rubocop:disable Metrics/BlockLength
RSpec.describe StoryBranch::GitUtils do
  let(:distances) { [3, 4, 3, 4] }
  let(:branches) { %w[amazing-name-1 amazing-feature-2] }

  before do
    allow(StoryBranch::GitWrapper).to receive(:branch_names)
      .and_return(branches)
    allow(DamerauLevenshtein).to receive(:distance).and_return(*distances)
  end

  describe 'existing_branch?' do
    it 'determnines levenshtein distance between branch name and branch list' do
      StoryBranch::GitUtils.existing_branch?('new-branch-name')
      expect(DamerauLevenshtein).to have_received(:distance)
        .with('amazing-name-1', 'new-branch-name')
      expect(DamerauLevenshtein).to have_received(:distance)
        .with('amazing-name', 'new-branch-name')
      expect(DamerauLevenshtein).to have_received(:distance)
        .with('amazing-feature-2', 'new-branch-name')
      expect(DamerauLevenshtein).to have_received(:distance)
        .with('amazing-feature', 'new-branch-name')
    end

    describe 'when levenshtein distance is not close' do
      let(:distances) { [3, 4, 3, 4] }

      it 'returns false' do
        expect(StoryBranch::GitUtils.existing_branch?('new-branch')).to eq false
      end
    end

    describe 'when levenshtein distance is close' do
      let(:distances) { [2] }
      it 'returns false' do
        expect(StoryBranch::GitUtils.existing_branch?('new-branch')).to eq true
      end
    end
  end

  describe 'branch_for_story_exists?' do
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

  describe 'current_branch_story_parts' do
    let(:branch) { 'amazing-feature-1' }

    before do
      allow(StoryBranch::GitWrapper).to receive(:current_branch)
        .and_return(branch)
    end

    it 'returns story title and id' do
      expect(StoryBranch::GitUtils.current_branch_story_parts).to eq(
        title: 'amazing feature', id: 1
      )
    end
  end
end
# rubocop:enable Metrics/BlockLength

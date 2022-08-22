# frozen_string_literal: true

require 'spec_helper'
require 'story_branch/git_utils'

RSpec.describe StoryBranch::GitUtils do
  let(:distances) { [3, 4, 3, 4] }
  let(:branches) { %w[amazing-name-1 amazing-feature-2] }

  before do
    allow(StoryBranch::Git::Wrapper).to receive(:branch_names)
      .and_return(branches)
    allow(DamerauLevenshtein).to receive(:distance).and_return(*distances)
  end

  describe 'similar_branch?' do
    it 'determnines levenshtein distance between branch name and branch list' do
      StoryBranch::GitUtils.similar_branch?('new-branch-name')
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
        expect(StoryBranch::GitUtils.similar_branch?('new-branch')).to eq false
      end
    end

    describe 'when levenshtein distance is close' do
      let(:distances) { [2] }
      it 'returns false' do
        expect(StoryBranch::GitUtils.similar_branch?('new-branch')).to eq true
      end
    end
  end

  describe 'branch_to_story_string' do
    let(:branch) { 'amazing-feature-1' }

    before do
      allow(StoryBranch::Git::Wrapper).to receive(:current_branch)
        .and_return(branch)
    end

    context 'when no regex is passed' do
      it 'returns regex matching between current branch and default regex' do
        res = StoryBranch::GitUtils.branch_to_story_string
        expect(res[0]).to eq branch
        expect(res[1]).to eq '1'
      end
    end

    context 'when regex is passed' do
      it 'returns regex matching between current branch and default regex' do
        res = StoryBranch::GitUtils.branch_to_story_string(/bananas/)
        expect(res).to eq nil
      end
    end
  end
end

# frozen_string_literal: true

require 'spec_helper'
require 'story_branch/github/tracker'

# rubocop:disable Metrics/BlockLength
RSpec.describe StoryBranch::Github::Tracker do
  it 'has the api endpoint defined' do
    expect(described_class::API_URL).to eq 'https://api.github.com/'
  end

  describe 'valid?' do
    describe 'when there is a repo name and an api key' do
      it 'is true' do
        tracker = described_class.new('reponame', 'apikey')
        expect(tracker.valid?).to eq true
      end
    end

    describe 'when there is a repo name but no api key' do
      it 'is false' do
        tracker = described_class.new('reponame', nil)
        expect(tracker.valid?).to eq false
      end
    end

    describe 'when there is an api key but no repo name' do
      it 'is false' do
        tracker = described_class.new(nil, 'apikey')
        expect(tracker.valid?).to eq false
      end
    end
  end

  describe 'get_stories' do
    let(:blanket_wrapper) { double(Blanket::Wrapper) }
    let(:mock_project) { double(StoryBranch::Github::Project, stories: []) }

    before do
      allow(Blanket).to receive(:wrap).and_return(blanket_wrapper)
      allow(blanket_wrapper).to receive(:repos).and_return('repo')
      allow(StoryBranch::Github::Project).to receive(:new)
        .and_return(mock_project)
      tracker = described_class.new('reponame', 'apikey')
      tracker.stories
    end

    it 'initializes the blanket api wrapper' do
      expect(Blanket).to have_received(:wrap).with(
        'https://api.github.com/',
        headers: {
          'User-Agent' => 'Story Branch',
          Authorization: 'token apikey'
        }
      )
    end

    it 'initializes the project' do
      expect(StoryBranch::Github::Project).to have_received(:new).with('repo')
    end

    it 'fetches the stories from the project' do
      expect(mock_project).to have_received(:stories)
    end
  end
end
# rubocop:enable Metrics/BlockLength

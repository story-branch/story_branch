# frozen_string_literal: true

require 'spec_helper'
require 'story_branch/main'
require 'story_branch/config_manager'
require 'story_branch/git_utils'

# rubocop:disable Metrics/BlockLength
RSpec.describe StoryBranch::Main do
  let(:prompt) { TTY::TestPrompt.new }
  let(:sb) { StoryBranch::Main.new }
  let(:current_branch_name) { 'rspec-testing' }
  let(:branch_exists) { false }
  let(:similar_branch) { false }

  before do
    allow(StoryBranch::GitUtils).to receive(:current_branch).and_return current_branch_name
    allow(StoryBranch::GitUtils).to receive(:branch_for_story_exists?).and_return branch_exists
    allow(StoryBranch::GitUtils).to receive(:existing_branch?).and_return similar_branch
    allow(StoryBranch::GitUtils).to receive(:create_branch?).and_return true
    allow(::TTY::Prompt).to receive(:new).and_return(prompt)
    allow(prompt).to receive(:select).and_call_original
    allow(StoryBranch::ConfigManager).to receive(:init_config) do |arg|
      conf = ::TTY::Config.new
      if arg == '.'
        conf.set('project_id', value: '123456')
      elsif arg == Dir.home
        conf.set('123456', 'api_key', value: 'myamazingkey')
      end
      conf
    end
    sb
  end

  it 'loads the config files' do
    expect(StoryBranch::ConfigManager).to have_received(:init_config).exactly(2).times
  end

  it 'initializes the PivotalTracker utils' do
    expect(sb.tracker).to_not be(nil)
    expect(sb.tracker.valid?).to eq true
  end

  describe 'create_story_branch' do
    let(:stories) { [] }

    before do
      allow(sb.tracker).to receive(:get_stories).and_return stories
      sb.create_story_branch
    end

    it 'gets the stories from the tracker' do
      expect(sb.tracker).to have_received(:get_stories).with('started')
    end

    describe 'when there are no features' do
      let(:stories) { [] }

      it 'prints message informing the user' do
        expect(prompt.output.string).to match('No stories started, exiting')
      end
    end

    describe 'when there are features' do
      let(:stories) do
        fake_story = OpenStruct.new(name: 'test', id: '123456')
        story = StoryBranch::Story.new(fake_story)
        prompt.input << story.to_s
        prompt.input.rewind
        [story]
      end
      let(:story) { stories[0] }

      it 'passes an structure to prompt select with story and text' do
        expected_select = {
          story.to_s => story
        }
        expect(prompt).to have_received(:select).with(
          'Choose the feature you want to work on:',
          expected_select,
          filter: true
        )
      end

      describe 'when the story id doesnt have a branch yet' do
        let(:branch_exists) { false }
        it 'creates the branch for the feature based on the feature name' do
          branch_name = "#{story.dashed_title} - #{story.id}"
          expect(GitUtils).to have_received(:create_branch).with(branch_name)
        end
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength

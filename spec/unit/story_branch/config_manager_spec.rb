# frozen_string_literal: true

require 'spec_helper'
require 'story_branch/config_manager'

RSpec.describe StoryBranch::ConfigManager do
  let(:prompt) { TTY::Prompt::Test.new }

  let!(:local_config) do
    conf = ::TTY::Config.new
    conf.filename = '.story_branch'
    conf.append_path '.'
    conf.set('project_id', value: %w[123456 54321])
    conf.write(force: true)
  end
  let!(:global_config) do
    FileUtils.mkdir_p Dir.home
    conf = ::TTY::Config.new
    conf.filename = '.story_branch'
    conf.append_path Dir.home
    conf.set('123456', 'api_key', value: 'myamazingkey')
    conf.write(force: true)
  end
  let(:sb_config) { described_class.new }

  before do
    allow(::TTY::Prompt).to receive(:new).and_return(prompt)
    allow(prompt).to receive(:select).and_return '123456'
  end

  it 'is a valid configuration' do
    expect(sb_config.valid?).to eq true
  end

  describe 'when there are multiple local projects configured' do
    it 'prompts the user to choose the project to use' do
      sb_config.valid?
      expect(prompt).to have_received(:select)
        .with('Which project you want to fetch from?', %w[123456 54321])
    end
  end

  describe 'tracker_type' do
    it 'defaults to pivotal-tracker' do
      expect(sb_config.tracker_type).to eq 'pivotal-tracker'
    end
  end

  describe 'issue_placement' do
    it 'defaults to End' do
      expect(sb_config.issue_placement).to eq 'End'
    end
  end

  describe 'finish_tag' do
    it 'defaults to Finishes' do
      expect(sb_config.finish_tag).to eq 'Finishes'
    end
  end

  describe 'branch_username' do
    it 'defaults to nil' do
      expect(sb_config.branch_username).to eq nil
    end

    context 'when a value is set' do
      let!(:global_config) do
        FileUtils.mkdir_p Dir.home
        conf = ::TTY::Config.new
        conf.filename = '.story_branch'
        conf.append_path Dir.home
        conf.set('123456', 'api_key', value: 'myamazingkey')
        conf.set('123456', 'branch_username', value: 'zebananas')
        conf.write(force: true)
      end

      it 'uses the value from the config' do
        expect(sb_config.branch_username).to eq 'zebananas'
      end
    end
  end
end

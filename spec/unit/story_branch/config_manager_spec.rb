# frozen_string_literal: true

require 'spec_helper'
require 'story_branch/config_manager'

RSpec.describe StoryBranch::ConfigManager do
  def create_local_config(file_path:)
    conf = ::TTY::Config.new
    conf.filename = '.story_branch'
    conf.append_path file_path
    conf.set('project_id', value: %w[123456 54321])
    conf.write(force: true)
  end

  def create_global_config(settings = [])
    FileUtils.mkdir_p Dir.home
    conf = ::TTY::Config.new
    conf.filename = '.story_branch'
    conf.append_path Dir.home
    settings.each do |setting|
      conf.set(setting[:project_id], setting[:key], setting[:value])
    end
    conf.write(force: true)
  end

  let(:prompt) { TTY::Prompt::Test.new }
  let(:sb_config) { described_class.new }

  before do
    create_local_config('.')
    create_global_config([{ project_id: '123456', key: 'api_key', value: 'myamazingkey' }])
    allow(::TTY::Prompt).to receive(:new).and_return(prompt)
    allow(prompt).to receive(:select).and_return '123456'
  end

  it 'is a valid configuration' do
    expect(sb_config.valid?).to be true
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
      expect(sb_config.branch_username).to be_nil
    end

    context 'when a value is set' do
      create_global_config(
        [{ project_id: '123456', key: 'api_key', value: 'myamazingkey' },
         { project_id: '123456', key: 'branch_username', value: 'zebananas' }]
      )

      it 'uses the value from the config' do
        expect(sb_config.branch_username).to eq 'zebananas'
      end
    end
  end

  describe 'when the local config is not in the current path' do
    let(:git_root_path) { '/tmp/' }

    before do
      create_local_config(file_path: git_root_path)
      allow(::StoryBranch::Git::Wrapper).to receive(:command).and_return(git_root_path)
    end

    it 'is a valid configuration' do
      expect(sb_config.valid?).to be true
    end
  end
end

# frozen_string_literal: true

require 'spec_helper'
require 'story_branch/commands/add'

# rubocop:disable Metrics/BlockLength
RSpec.describe StoryBranch::Commands::Add do
  let(:prompt) { instance_double('TTY::Prompt') }
  let(:config_directory) { FileUtils.mkdir_p Dir.home }

  before do
    allow(TTY::Prompt).to receive(:new).and_return(prompt)
    allow(prompt).to receive(:ask).and_return('amazingkey', '123456')
    allow(prompt).to receive(:select).and_return('pivotal-tracker')

    FakeFS.with_fresh do
      config_directory
      command = StoryBranch::Commands::Add.new({})
      command.execute
    end
  end

  describe 'when there is no config file' do
    it 'creates a new config in home directory' do
      config = TTY::Config.new
      config.append_path(Dir.home)
      config.filename = '.story_branch'
      expect(config.persisted?).to eq true
      config.read
      expect(config.fetch('123456', :api_key)).to eq 'amazingkey'
    end

    it 'creates a new local config file' do
      config = TTY::Config.new
      config.append_path('.')
      config.filename = '.story_branch'
      expect(config.persisted?).to eq true
      config.read
      expect(config.fetch(:project_id)).to eq ['123456']
      expect(config.fetch(:tracker)).to eq 'pivotal-tracker'
    end
  end

  describe 'when there is an existing config file' do
    let(:config_directory) do
      FileUtils.mkdir_p Dir.home
      config = TTY::Config.new
      config.append_path(Dir.home)
      config.filename = '.story_branch'
      config.set('1234560000', :api_key, value: 'amazingkey0000')
      config.write

      local_config = TTY::Config.new
      local_config.append_path('.')
      local_config.filename = '.story_branch'
      local_config.set(:project_id, value: '1234560000')
      local_config.write
    end

    it 'appends the new config to the home directory' do
      config = TTY::Config.new
      config.append_path(Dir.home)
      config.filename = '.story_branch'
      expect(config.persisted?).to eq true
      config.read
      expect(config.fetch('1234560000', :api_key)).to eq 'amazingkey0000'
      expect(config.fetch('123456', :api_key)).to eq 'amazingkey'
    end

    describe 'when the local config does not have the project id' do
      it 'appends to the local config file' do
        config = TTY::Config.new
        config.append_path('.')
        config.filename = '.story_branch'
        expect(config.persisted?).to eq true
        config.read
        expect(config.fetch(:project_id)).to eq %w[1234560000 123456]
      end
    end

    describe 'when the local config already has the project id' do
      let(:config_directory) do
        FileUtils.mkdir_p Dir.home
        config = TTY::Config.new
        config.append_path(Dir.home)
        config.filename = '.story_branch'
        config.set('1234560000', :api_key, value: 'amazingkey0000')
        config.write

        local_config = TTY::Config.new
        local_config.append_path('.')
        local_config.filename = '.story_branch'
        local_config.set(:project_id, value: '1234560000')
        local_config.append('123456', to: :project_id)
        local_config.write
      end

      it 'does nothing' do
        config = TTY::Config.new
        config.append_path('.')
        config.filename = '.story_branch'
        expect(config.persisted?).to eq true
        config.read
        expect(config.fetch(:project_id)).to eq %w[1234560000 123456]
      end
    end

    describe 'when the local config only has that project id' do
      let(:config_directory) do
        FileUtils.mkdir_p Dir.home
        config = TTY::Config.new
        config.append_path(Dir.home)
        config.filename = '.story_branch'
        config.set('123456', :api_key, value: 'amazingkey')
        config.write

        local_config = TTY::Config.new
        local_config.append_path('.')
        local_config.filename = '.story_branch'
        local_config.set(:project_id, value: '123456')
        local_config.write
      end

      it 'does nothing' do
        config = TTY::Config.new
        config.append_path('.')
        config.filename = '.story_branch'
        expect(config.persisted?).to eq true
        config.read
        expect(config.fetch(:project_id)).to eq '123456'
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength

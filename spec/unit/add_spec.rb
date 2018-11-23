# frozen_string_literal: true

require 'spec_helper'
require 'story_branch/commands/add'

# rubocop:disable Metrics/BlockLength
RSpec.describe StoryBranch::Commands::Add do
  let(:prompt) { TTY::TestPrompt.new }
  let(:config_directory) do
    FileUtils.mkdir_p 'tmp'
    FileUtils.mkdir_p Dir.home
  end

  before do
    allow(::TTY::Prompt).to receive(:new).and_return(prompt)
    prompt.input << "amazingkey\r123456"
    prompt.input.rewind

    FakeFS.with_fresh do
      config_directory
      command = StoryBranch::Commands::Add.new({})
      command.execute
    end
  end

  describe 'prompting the user' do
    it 'prompts the user for the api key' do
      question = 'Please provide the api key:'
      expect(prompt.output.string).to match(question)
    end

    it 'prompts the user for the project id' do
      question = "Please provide this project's id:"
      expect(prompt.output.string).to match(question)
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
    end
  end

  describe 'when there is an existing config file' do
    let(:config_directory) do
      FileUtils.mkdir_p 'tmp'
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

    it 'appends to the local config file' do
      config = TTY::Config.new
      config.append_path('.')
      config.filename = '.story_branch'
      expect(config.persisted?).to eq true
      config.read
      expect(config.fetch(:project_id)).to eq %w[1234560000 123456]
    end
  end
end
# rubocop:enable Metrics/BlockLength

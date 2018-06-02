require 'spec_helper'
require 'story_branch/commands/add'

RSpec.describe StoryBranch::Commands::Add do
  let(:prompt) { TTY::TestPrompt.new }

  before do
    allow(::TTY::Prompt).to receive(:new).and_return(prompt)
    prompt.input << "amazingkey\r123456\rtest-project"
    prompt.input.rewind

    FakeFS.with_fresh do
      FileUtils.mkdir_p Dir.home
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
      expect(config.fetch('test-project', :api_key)).to eq 'amazingkey'
      expect(config.fetch('test-project', :project_id)).to eq '123456'
    end

    it 'creates a new local config file' do
      config = TTY::Config.new
      config.append_path('.')
      config.filename = '.story_branch'
      expect(config.persisted?).to eq true
      config.read
      expect(config.fetch(:project_name)).to eq 'test-project'
    end

    describe 'prompting the user' do
      it 'prompts the user for the project name' do
        question = "What should be this project's name\?"
        expect(prompt.output.string).to match(question)
      end

      it 'prompts the user for the api key' do
        question = 'Please provide the api key:'
        expect(prompt.output.string).to match(question)
      end

      it 'prompts the user for the project id' do
        question = "Please provide this project's id:"
        expect(prompt.output.string).to match(question)
      end
    end
  end
end

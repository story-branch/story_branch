require 'spec_helper'
require 'story_branch/commands/config'

RSpec.describe StoryBranch::Commands::Config do
  let(:prompt) { instance_double(::TTY::Prompt, ask: 'ask') }

  before do
    allow(::TTY::Prompt).to receive(:new).and_return(prompt)
    FakeFS.with_fresh do
      FileUtils.mkdir_p Dir.home
      command = StoryBranch::Commands::Config.new({})
      command.execute
    end
  end

  describe 'when there is no config file' do
    it 'creates a new config in home directory' do
      home_dir_config = "#{Dir.home}/.story_branch.yml"
      expect(File.exist?(home_dir_config)).to eq true
    end

    describe 'prompting the user' do
      it 'prompts the user for the project name' do
        question = "What should be this project's name?"
        expect(prompt).to have_received(:ask).with(question)
      end
      it 'prompts the user for the api key' do
        question = 'Please provide the api key?'
        expect(prompt).to have_received(:ask).with(question)
      end

      it 'prompts the user for the project id' do
        question = 'Please provide the project id?'
        expect(prompt).to have_received(:ask).with(question)
      end
    end
  end
end

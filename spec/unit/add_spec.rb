require 'spec_helper'
require 'story_branch/commands/add'

RSpec.describe StoryBranch::Commands::Add do
  let(:prompt) { TTY::TestPrompt.new }

  before do
    allow(::TTY::Prompt).to receive(:new).and_return(prompt)
    prompt.output << nil
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
      home_dir_config = "#{Dir.home}/.story_branch.yml"
      expect(File.exist?(home_dir_config)).to eq true
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

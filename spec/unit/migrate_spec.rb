require 'spec_helper'
require 'story_branch/commands/migrate'

RSpec.describe StoryBranch::Commands::Migrate do
  describe 'when no configuration is found in any of the possibilities' do
    let(:config_directory) { FileUtils.mkdir_p Dir.home }
    let(:command) { StoryBranch::Commands::Migrate.new({}) }
    let(:output) { ::StringIO.new }

    before do
      ENV['PIVOTAL_API_KEY'] = ''
      ENV['PIVOTAL_PROJECT_ID'] = ''
      FakeFS.with_fresh do
        config_directory
        command.execute(output: output)
      end
    end

    it 'should print an informative error message' do
      expected_message = <<-MESSAGE
Old configuration not found.
Trying to start from scratch? Use story_branch add
      MESSAGE

      expect(output.string).to eq expected_message
    end
  end
  # TODO:
  # - When no configuration is found
  # - it should output a message telling them what to do - aka run add

  # - When the user has configuration in env vars
  # - When the user has configuration in local folder and home folder
  # - When the user has configuration in home folder only
end

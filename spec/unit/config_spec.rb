require 'fakefs/spec_helpers'
require 'story_branch/commands/config'

RSpec.describe StoryBranch::Commands::Config do
  describe 'when there is no config file' do
    it 'creates a new config in home directory' do
      home_dir_config = "#{Dir.home}/.story_branch.yml"
      expect(File.exist?(home_dir_config)).to eq false
      command = StoryBranch::Commands::Config.new({})
      command.execute
      expect(File.exist?(home_dir_config)).to eq true
    end
  end
end

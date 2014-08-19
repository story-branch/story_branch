require 'spec_helper'

## NOTE: This is a pretty limited test suite to check the config
## loading (key and project id)

describe StoryBranch do

  before :each do
    clear_env_variables
    clear_config_file
  end

  after :all do
    clear_config_file
  end

  let(:project_id_error_message_rx) { Regexp.new(/\$PIVOTAL_PROJECT_ID must be set or in \.story_branch/) }
  let(:api_key_error_message_rx)    { Regexp.new(/\$PIVOTAL_API_KEY must be set or in \.story_branch/) }

  describe StoryBranch::Main do

    context "Story Branch initialization" do

      context "environment variable PIVOTAL_API_KEY not set" do
        it "should exit with error message if no config file is found in the current path" do
          expect{begin StoryBranch::Main.new; rescue SystemExit; end}.to output(project_id_error_message_rx).to_stderr
          expect{begin StoryBranch::Main.new; rescue SystemExit; end}.to output(api_key_error_message_rx).to_stderr
        end

        it "should exit with error message config file found in path is empty" do
          copy_config_file "spec/files/.story_branch", true
          expect{begin StoryBranch::Main.new; rescue SystemExit; end}.to output(project_id_error_message_rx).to_stderr
          expect{begin StoryBranch::Main.new; rescue SystemExit; end}.to output(api_key_error_message_rx).to_stderr
        end
      end

      context "environment variable PIVOTAL_API_KEY is set" do
        it "should exit with error message if no PIVOTAL_PROJECT_ID is defined in enviroment and no config file is found in the current path" do
          ENV['PIVOTAL_API_KEY']="ABC123DEF"
          expect{begin StoryBranch::Main.new; rescue SystemExit; end}.to output(project_id_error_message_rx).to_stderr
          expect{begin StoryBranch::Main.new; rescue SystemExit; end}.not_to output(api_key_error_message_rx).to_stderr
        end

        it "should exit with error message if config file found in current path is empty" do
          ENV['PIVOTAL_API_KEY']="ABC123DEF"
          copy_config_file "spec/files/.story_branch", true
          expect{begin StoryBranch::Main.new; rescue SystemExit; end}.to output(project_id_error_message_rx).to_stderr
          expect{begin StoryBranch::Main.new; rescue SystemExit; end}.not_to output(api_key_error_message_rx).to_stderr
        end
      end

      it "should be a valid object with api_key and project_id both set based on environmental variables" do
        ENV['PIVOTAL_API_KEY']="ABC123DEF"
        ENV['PIVOTAL_PROJECT_ID']="ABC123DEF"
        expect{begin StoryBranch::Main.new; rescue SystemExit; end}.not_to output(project_id_error_message_rx).to_stderr
        expect{begin StoryBranch::Main.new; rescue SystemExit; end}.not_to output(api_key_error_message_rx).to_stderr
      end

      it "should be a valid object with api key set based on environment and project_id set based on config file" do
        ENV['PIVOTAL_API_KEY']="ABC123DEF"
        copy_config_file "spec/files/.story_branch", false
        expect{begin StoryBranch::Main.new; rescue SystemExit; end}.to_not output(project_id_error_message_rx).to_stderr
        expect{begin StoryBranch::Main.new; rescue SystemExit; end}.to_not output(api_key_error_message_rx).to_stderr
      end

      it "should be a valid object with api key set based on config file and project_id set based on environment" do
        copy_config_file "spec/files/.story_branch", false
        ENV['PIVOTAL_PROJECT_ID']="ABC123DEF"
        expect{begin StoryBranch::Main.new; rescue SystemExit; end}.to_not output(project_id_error_message_rx).to_stderr
        expect{begin StoryBranch::Main.new; rescue SystemExit; end}.to_not output(api_key_error_message_rx).to_stderr
      end

      it "should be a valid object with api_key and project_id both set based on config files" do
        copy_config_file "spec/files/.story_branch", false
        expect{begin StoryBranch::Main.new; rescue SystemExit; end}.to_not output(project_id_error_message_rx).to_stderr
        expect{begin StoryBranch::Main.new; rescue SystemExit; end}.to_not output(api_key_error_message_rx).to_stderr
      end
    end

  end
end

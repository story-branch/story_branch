require 'spec_helper'
describe StoryBranch do
  let (:sb) {}
  context "Story Branch initialization" do
    
    context "no PIVOTAL_API_KEY defined in env" do
      it "should exit with error message if no config file is found in the current path" do
        expect{
          sb = StoryBranch.new
        }.to raise_error("PIVOTAL_API_KEY must be set")
        expect(sb).to be_nil
      end

      it "should exit with error message config file found in path is empty" do
        copy_config_files %w(spec/files/.pivotal_api_key), %w(true)
        expect{
          sb = StoryBranch.new
        }.to raise_error("Existing .pivotal_api_key config file found, but without contents")
        expect(sb).to be_nil
      end
    end

    context "PIVOTAL_API_KEY is set" do
      it "should exit with error message if no PIVOTAL_PROJECT_ID is defined in enviroment and no config file is found in the current path" do
        ENV['PIVOTAL_API_KEY']="ABC123DEF"
        expect{
          sb = StoryBranch.new
        }.to raise_error("PIVOTAL_PROJECT_ID must be set")
        expect(sb).to be_nil
      end
  
      it "should exit with error message if config file found in current path is empty" do
        ENV['PIVOTAL_API_KEY']="ABC123DEF"
        copy_config_files %w(spec/files/.pivotal_project_id), %w(true)
        expect{
          sb = StoryBranch.new
        }.to raise_error("Existing .pivotal_project_id config file found, but without contents")
        expect(sb).to be_nil
      end
    end

    it "should be a valid object with api_key and project_id both set based on environmental variables" do
      ENV['PIVOTAL_API_KEY']="ABC123DEF"
      ENV['PIVOTAL_PROJECT_ID']="ABC123DEF"
      expect{
        sb = StoryBranch.new
      }.to_not raise_error
      sb = StoryBranch.new
      expect sb.valid? == true
    end

    it "should be a valid object with api key set based on environment and project_id set based on config file" do
      ENV['PIVOTAL_API_KEY']="ABC123DEF"
      copy_config_files %w(spec/files/.pivotal_project_id)
      expect{
        sb = StoryBranch.new
      }.to_not raise_error
      sb = StoryBranch.new
      expect sb.valid? == true
    end

    it "should be a valid object with api key set based on config file and project_id set based on environment" do
      copy_config_files %w(spec/files/.pivotal_api_key)
      ENV['PIVOTAL_PROJECT_ID']="ABC123DEF"
      debugger
      expect{
        sb = StoryBranch.new
      }.to_not raise_error
      sb = StoryBranch.new
      expect sb.valid? == true
    end

    it "should be a valid object with api_key and project_id both set based on config files" do
      copy_config_files %w(spec/files/.pivotal_api_key spec/files/.pivotal_project_id)
      expect{
        sb = StoryBranch.new
      }.to_not raise_error
      sb = StoryBranch.new
      expect sb.valid? == true
    end
  end

  context "Story Branch is initialized correctly" do

    it "should be able to fetch a list of available stories" do

    end

  end
end
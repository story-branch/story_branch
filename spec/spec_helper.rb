#require 'story_branch'
require_relative '../lib/story_branch'

RSpec.configure do |config|
  # some (optional) config here
  config.after(:each) do
    empty_config_files
    clear_env_variables
  end
end

def copy_config_files(filelist)
  FileUtils.cp filelist, '.'
end

def clear_env_variables
  ENV.delete("PIVOTAL_API_KEY")
  ENV.delete("PIVOTAL_PROJECT_ID")
end

def empty_config_files
  FileUtils.rm '.pivotal_api_key' rescue "File not found"
  FileUtils.rm '.pivotal_project_id' rescue "File not found"
end
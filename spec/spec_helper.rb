require 'story_branch'
#require_relative '../lib/story_branch'

RSpec.configure do |config|
  # some (optional) config here
  config.after(:each) do
    empty_config_files
    clear_env_variables
  end
end

def copy_config_files(filelist, empty_contents = [])
  FileUtils.cp filelist, '.'
  if empty_contents.empty?
    empty_contents = Array.new(filelist.length, false)
  end
  empty_contents.to_enum.with_index.each do |to_empty, i|
    if to_empty
      f = File.basename(filelist[i])
      File.open("./#{f}", 'w') {|file| file.truncate(0) }
    end
  end
end

def clear_env_variables
  ENV.delete("PIVOTAL_API_KEY")
  ENV.delete("PIVOTAL_PROJECT_ID")
end

def empty_config_files
  FileUtils.rm '.pivotal_api_key' rescue "File not found"
  FileUtils.rm '.pivotal_project_id' rescue "File not found"
end
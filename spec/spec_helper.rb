require_relative '../lib/story_branch'
require 'pry'

RSpec.configure do |config|
  # some (optional) config here
end

def copy_config_file(filename, empty_contents=false)
  FileUtils.cp filename, '.'
  if empty_contents
    File.open("./#{File.basename(filename)}", 'w') {|file| file.truncate(0) }
  end
end

def clear_env_variables
  ENV.delete("PIVOTAL_API_KEY")
  ENV.delete("PIVOTAL_PROJECT_ID")
end

def clear_config_file
  FileUtils.rm '.story_branch' rescue "File not found"
end

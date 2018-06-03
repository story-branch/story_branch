require 'bundler/setup'
require 'fileutils'
require 'fakefs/safe'
require 'story_branch'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  # config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before do
    FakeFS.activate!
  end

  config.after do
    FakeFS.deactivate!
  end
end

def create_old_file
  File.open("#{Dir.home}/.story_branch", 'w') do |file|
    file.write("api: DUMMYVALUE\n")
    file.write("project: 213976\n")
  end
end

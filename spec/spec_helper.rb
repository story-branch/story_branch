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

# frozen_string_literal: true

require 'bundler/setup'
require 'fileutils'
require 'git'
require 'pp'
require 'fakefs/safe'
require 'story_branch'
require 'ostruct'

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

# TODO: Migrate this to use TTY::Config instead
def create_old_file(options = {})
  path = options[:path] || Dir.home
  full = if options[:full].nil?
           true
         else
           options[:full]
         end
  api_key = options[:api_key] || 'DUMMYVALUE'
  project_id = options[:project_id] || '213976'
  write_configs(path, api_key, project_id, full)
end

def write_configs(path, api_key, project_id, full = true)
  File.open("#{path}/.story_branch", 'w') do |file|
    file.write("api: #{api_key}\n") if full
    file.write("project: #{project_id}\n")
  end
end

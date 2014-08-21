# encoding: utf-8

$:.unshift File.expand_path('../lib', __FILE__)
require 'story_branch/version'

Gem::Specification.new do |s|
  s.name        = "story_branch"
  s.version     = StoryBranch::VERSION
  s.date        = "2014-06-24"
  s.summary     = "Story Branch - create git branches based on pivotal tracker stories"
  s.description = "Simple gem that fetches the available stories in your pivotaltracker project and allows you to create a git branch with the name based on the selected story"
  s.authors     = ["Jason Milkins",
                   "Rui Baltazar",
                   "Dominic Wong",
                   "Gabe Hollombe"]
  s.email       = ["jasonm23@gmail.com",
                   "rui.p.baltazar@gmail.com",
                   "dominic.wong.617@gmail.com",
                   "gabe@neo.com"]
  s.files       = Dir['lib/*.rb'] + Dir['bin/*'] + %W(README.md LICENCE)
  s.homepage    = "https://github.com/jasonm23/story_branch"
  s.license     = "MIT"

  #Runtime Dependencies
  s.required_ruby_version = ">= 1.9.3"
  s.add_runtime_dependency "pivotal-tracker","~> 0.5"
  s.add_runtime_dependency "git", "~> 1.2"
  s.add_runtime_dependency "levenshtein-ffi", "~> 1.0"
  s.add_runtime_dependency "rb-readline", "~> 0.5"

  #Development dependencies
  s.add_development_dependency "rspec", "~> 3.0"

  #Scripts available after instalation
  s.executables  = %w(
                      story_start story-start git-start git-story-start
                      story_branch story-branch git-story git-story-branch git-pivotal-story
                      story_finish story-finish git-finish git-story-finish
                     )
end

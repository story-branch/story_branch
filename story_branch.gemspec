# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'story_branch/version'

# rubocop:disable Metrics/BlockLength
Gem::Specification.new do |spec|
  spec.name = 'story_branch'
  spec.license = 'MIT'
  spec.version = StoryBranch::VERSION
  spec.authors = [
    'Rui Baltazar',
    'Jason Milkins',
    'Dominic Wong',
    'Ranhiru Cooray',
    'Gabe Hollombe'
  ]
  spec.email = [
    'rui.p.baltazar@gmail.com',
    'jasonm23@gmail.com',
    'dominic.wong.617@gmail.com',
    'ranhiru@gmail.com',
    'gabe@neo.com'
  ]

  spec.summary = 'Create git branches based on your preferred tracker tickets'
  spec.description = <<~DESCRIPTION
    This simple gem allows you to create a branch based on the existing issues
    in your preferred tracker. It integrates with PivotalTracker, Github and
    JIRA. Different workflows shall be supported in the next versions.
  DESCRIPTION

  spec.homepage    = 'https://github.com/story-branch/story_branch'

  spec.metadata = {
    'bug_tracker_uri' => 'https://github.com/story-branch/story_branch/issues',
    'changelog_uri' => 'https://github.com/story-branch/story_branch/blob/master/Changelog.md',
    'documentation_uri' => 'https://github.com/story-branch/story_branch/blob/master/README.md',
    'source_code_uri' => 'https://github.com/story-branch/story_branch'
  }
  spec.required_ruby_version = ['>= 2.4', '< 3.1']

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been
  # added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      f.match(%r{^(test|spec|features)/})
    end
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'blanket_wrapper', '~> 3.0', '> 3.0'
  spec.add_runtime_dependency 'damerau-levenshtein', '~> 1.3', '> 1.3'
  spec.add_runtime_dependency 'httparty', '>0'
  spec.add_runtime_dependency 'jira-ruby', '> 1.7', '< 3'
  spec.add_runtime_dependency 'story_branch-graphql', '~> 0.0.2'
  spec.add_runtime_dependency 'story_branch-git_wrapper', '~> 0.0.2'
  spec.add_runtime_dependency 'thor', '> 0.20', '< 2'
  spec.add_runtime_dependency 'tty-command', '~> 0.8', '> 0.8'
  spec.add_runtime_dependency 'tty-config', '~> 0.2', '> 0.2'
  spec.add_runtime_dependency 'tty-pager',  '~> 0.12', '> 0.12'
  spec.add_runtime_dependency 'tty-prompt', '~> 0.18', '> 0.18'
  spec.add_runtime_dependency 'xdg', '> 3.0', '< 6'

  spec.add_development_dependency 'bundler', '~> 2.1', '> 2.1'
  spec.add_development_dependency 'fakefs', '> 0.14', '< 2'
  spec.add_development_dependency 'git', '~> 1.5', '> 1.5'
  spec.add_development_dependency 'ostruct', '~> 0.1', '> 0.1'
  spec.add_development_dependency 'pry', '~> 0.11', '> 0.11'
  spec.add_development_dependency 'rake', '>= 12.3.3', '< 14'
  spec.add_development_dependency 'rspec', '~> 3', '> 3'
  spec.add_development_dependency 'rspec_junit_formatter', '~> 0.4', '> 0.4'
  spec.add_development_dependency 'rubocop', '~> 1.22'
  spec.add_development_dependency 'simplecov', '~> 0.16', '> 0.16'
end
# rubocop:enable Metrics/BlockLength

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

  spec.summary = 'Create git branches based on pivotal tracker stories'
  spec.description = <<~DESCRIPTION
    Simple gem that fetches the available stories in your PivotalTracker
    project and allows you to create a git branch with the name based
    on the selected story
  DESCRIPTION

  spec.metadata = {
    'bug_tracker_uri' => 'https://github.com/story-branch/story_branch/issues',
    'changelog_uri' => 'https://github.com/story-branch/story_branch/blob/master/Changelog.md',
    'documentation_uri' => 'https://github.com/story-branch/story_branch/blob/master/README.md',
    'homepage_uri' => 'https://github.com/story-branch/story_branch',
    'source_code_uri' => 'https://github.com/story-branch/story_branch'
  }
  spec.required_ruby_version = ['>= 2.3', '< 2.7']

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

  spec.add_runtime_dependency 'blanket_wrapper', '~> 3.0'
  spec.add_runtime_dependency 'damerau-levenshtein', '~> 1.3'
  spec.add_runtime_dependency 'thor', '~> 0.20.0'
  spec.add_runtime_dependency 'tty-command', '~> 0.8.2'
  spec.add_runtime_dependency 'tty-config', '~> 0.2.0'
  spec.add_runtime_dependency 'tty-pager', '~> 0.12'
  spec.add_runtime_dependency 'tty-prompt', '~> 0.18'

  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'fakefs', '~> 0.14'
  spec.add_development_dependency 'git', '~> 1.5'
  spec.add_development_dependency 'ostruct', '~> 0.1'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3'
  spec.add_development_dependency 'rspec_junit_formatter', '~> 0.4'
end
# rubocop:enable Metrics/BlockLength

Gem::Specification.new do |s|
  s.name        = "story_branch"
  s.version     = "0.1.7"
  s.date        = "2014-06-06"
  s.summary     = "Story Branch - create git branches based on pivotal tracker stories"
  s.description = "Simple gem that fetches the available stories in your pivotaltracker project and allows you to create a git branch with the name based on the selected story"
  s.authors     = ["Jason Milkins", "Gabe Hollombe", "Rui Baltazar", "Dominic Wong"]
  s.email       = ["jasonm23@gmail.com", "gabe@neo.com", "rui.p.baltazar@gmail.com", "dominic.wong.617@gmail.com"]
  s.files       = Dir['lib/*.rb'] + Dir['bin/*'] + %W(README.md LICENCE)
  s.homepage    = "https://github.com/jasonm23/pivotal-story-branch"
  s.license     = "MIT"

  #Runtime Dependencies
  s.required_ruby_version = ">= 1.9.3"
  s.add_runtime_dependency "pivotal-tracker","~> 0.5"
  s.add_runtime_dependency "git", "~> 1.2"
  s.add_runtime_dependency "levenshtein-ffi", "~> 1.0"

  #Development dependencies
  s.add_development_dependency "rspec"

  #Scripts available after instalation
  s.executables  = ["story_branch", "story-branch", "git-story", "git-story-branch", "git-pivotal-story"]
end

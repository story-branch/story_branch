# 0.3.3
Tue Jun 26 15:18:37 2018 +0800

- Deploy to Rubygems via CI/CD - CircleCI

# 0.3.1
Tue Jun 26 15:18:37 2018 +0800

[Resolves #44] Story branch finish is broken
[Resolves #30] Update to use Ruby 2.3.0 minimum
[Resolves #32] Support multiple configurations
[Resolves #27] Allow config finish tag

- Making use of TTY Prompt to collect input from the user
- Cleaned up some code on PivotalUtils to simplify logic
- Improved test coverage
- Added minimum version to gemspec
- Added .ruby-version file with ruby 2.3.1.
- Cleanup a lot of the rubocop warnings
- Running the commands using TTY::Command
- Added Migrate command to upgrade current public version to new version
- Updated dependencies
- Updated readme for a more comprehensive usage

# 0.2.13
Tue Nov 14 15:12:58 2017 +0800

- Fix abort on empty config file

# 0.2.12
Wed Jun 8 11:07:06 2016 +0800

- Remove byebug since it is not in dependency
- Load config from different files (home dir or project local)

# 0.2.9
Fri May 15 14:03:00 2015 +0800

- Fix strip newlines

# 0.2.8
Tue May 12 17:47:22 2015 +0800

- Removed pivotal-tracker gem dependency,
- Using Blanket Wrapper to access Pivotal API

# 0.2.7
Tue Apr 14 18:57:34 2015 +0800

- Remove deprecated CLI bins

# 0.2.5
Wed Sep 17 11:20:20 2014 +0800

- Fix error story_branch/issues/15 on git finish
- Fix error story_branch/issues/16 newlines in story names
- Fix existing branch / story validation
- Improve / simplify error messages
- Improve name sanitisation
- Added story unstart

# 0.2.4
Fri Aug 22 14:27:47 2014 +0800

- Fixes problem with story finish

# 0.2.3
Thu Aug 21 10:53:21 2014 +0800

- Fix rb-readline dependency

# 0.2.3
Tue Aug 19 10:35:43 2014 +0800

- Fix specs and rspec reporter
- Use rb-readline
- Fix Readline completion, using rb-readline
- Add pry for debugging support
- Output errors to stderr
- Modify completion system, general improvements
- Humanize / undash the commit message description (from the branch name)

# 0.2.2
Tue Aug 12 17:43:30 2014 +0800

- Add start and finish stories.
- Fix path in symlinks

# 0.1.8
Tue Jun 24 11:09:32 2014 +0800

- Remove constraint to master as feature parent.
- Add aliases for story_branch executable

# 0.1.5
Mon May 26 10:34:12 2014 +0800

- tidy up output and add LICENCE

# 0.1.4
Thu May 15 09:58:03 2014 +0800

- Update name generation / translation rules
- Squeeze multiple dashes in suggested branch name
- Remove logging
- Ignore .pairs

# 0.1.1
Mon Apr 21 11:44:22 2014 +0800

- Updated code to require gem instead of relative paths
- Finishes #4 test definition
- Clear test files for tests specifications
- Searches for existing file or environment set variable. Existing file overrides the env var
- Raise PIVOTAL_API_KEY exception if api key not found in env. added method to check if object is set with api_key and project_id

# 0.0.1
Sat Apr 19 00:24:41 2014 +0800

- Add usage info (draft) to file header
- Add simple_sanitize method to remove common punctuation from story
  names / existing branch names
- Remove arbitrary 50 char limit on branch names
- Convert to a command utility gem + refactoring into a class
- Removed levenshtein dependency. added ruby min version


# 0.0.0
Sat Jan 25 19:04:01 2014 +0800

- Look for pivotal project id (.pivotal-id) in repo root (we assume
  we're in project root.) (we do this and fallback to checking
  environment var)
- Added Levenshtein Distance checking to branch names, to avoid names
  which are too close together (and straight-up duplicates)
- Added read-line support and re-factored
- Read-line support (to use instead of gets)
- Allow injection of history into read-line invocations
- Injected selection numbers into story selection read-line history
- Dashed / down-cased story name as a suggestion for the new feature
  branch name
- Injected dash/down-cased story name into new feature branch name
  read-line history (move up to get it)
- Fix error testing PIVOTAL_PROJECT_ID
- Rename ptrak to story_branch
- Basic version passing

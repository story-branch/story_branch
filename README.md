[![Gem Version](https://badge.fury.io/rb/story_branch.png)](http://badge.fury.io/rb/story_branch)
[![CircleCI](https://circleci.com/gh/story-branch/story_branch/tree/master.svg?style=svg)](https://circleci.com/gh/story-branch/story_branch/tree/master)

# Story Branch

Story branch is a CLI application that interacts with Pivotal Tracker at the
at the moment. It allows you to start and un-start stories as well as creating
branches based on the story name and id and have a final commit message marking
the story as Finished.

[View Changelog](Changelog.md)

## Installing

Install the gem:

    gem install story_branch

## Usage

You should run story_branch from the git/project root folder.

## Commands available

You can see all the commands available by running

```
$ story_branch -h

Commands:
  story_branch add             # Add a new story branch configuration
  story_branch create          # Create branch from estimated stories in pivotal tracker
  story_branch finish          # Creates a git commit message for the staged changes with a [Finishes] tag
  story_branch help [COMMAND]  # Describe available commands or one specific command
  story_branch migrate         # Migrate old story branch configuration to the new format
  story_branch start           # Mark an estimated story as started in Pivotal Tracker
  story_branch unstart         # Mark a started story as un-started in Pivotal Tracker
  story_branch version         # story_branch gem version
```

## Settings

Story branch has a command available that will help you creating the configurations
for the projects, but essentially you'll be asked for the pivotal tracker project id and your api key.

### Configuring the project id

The project id you can get it easily from the url when viewing the project.
This value will be stored in the local configuration file that will be committed
to the working repository

### Configuring the api key

The api key you can get it from your account settings.
This value will be stored in your global configuration file that typically is
not shared with your co-workers in the repository. This way, each user will
be properly identified in the tracker

### Configuring the finish tag

On your local config you can add a line with `finish_tag: <Some random word>`.
This tag will be used in the commit message when running `story_branch finish`.

E.g.
`finish_tag: Resolves`

`story_branch finish` will make a commit with the message
`[Resolves #12313] story title`


### .story_branch files

When configuring story branch, it will create two .story_branch.yml files: one in
your home folder (`~/`) and one in your project's root (`./`).
The one in your home folder will be used to store the different project's configurations
such as which api key to use. This is done so you don't need to commit your
api key to the repository but still be able to use different keys in case you
have different accounts.

The one in your project root will keep a reference to the project configuration.
For now, this reference is the project id. This file can be safely committed to
the repository and shared amongst your co-workers.

## Migrating

### Old configuration

If your were using story branch before there are some small changes on the way the
tool works. But worry not, we've written a command that allows you to migrate your
configuration. Running

`$ story_branch migrate`

will grab your existing configuration and convert it into the new format. The only
thing you'll need to provide is the project name reference.

### Old commands

Story branch was built providing a set of bin commands such as `git-story`, `git-finish`, `git-start` and `git-unstart`. These will be available still as
we try as much as possible to keep the updates retro-compatible, but are nothing
more than an alias for the CLI commands as follow:

- `git-story` runs `story_branch create`
- `git-finish` runs `story_branch finish`
- `git-start` runs `story_branch start`
- `git-unstart` runs `story_branch unstart`

## Commentary

`story_branch create`: Creates a git branch with automatic reference to a
Pivotal Tracker Story. It will get started stories from your active
project. You can enter text and press TAB to search for a story
name, or TAB to show the full list. It will then suggest an editable
branch name. When the branch is created the `story_id` will
be appended to it.

e.g. `my-story-name-1234567`

`story_branch finish`: Creates a git commit message for the staged changes.

e.g: `[Finishes #1234567] My story name`

You must stage all changes (or stash them) first. Note the commit will not
be pushed. Note: You'll be able to bail out of the commit.

`story_branch start`: Start a story in Pivotal Tracker from the terminal.
It'll get all un-started stories in your current project. You can
enter text and press TAB to search for a story name, or TAB to show
the full list.

`story_branch unstart`: Un-start a story in Pivotal Tracker from the terminal.
It'll get all started stories in your current project. You can
enter text and press TAB to search for a story name, or TAB to show
the full list.

## Contributing

All pull requests are welcome and will be reviewed.

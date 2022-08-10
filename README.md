[![Gem Version](https://badge.fury.io/rb/story_branch.png)](http://badge.fury.io/rb/story_branch)
[![CircleCI](https://circleci.com/gh/story-branch/story_branch/tree/master.svg?style=svg)](https://circleci.com/gh/story-branch/story_branch/tree/master)
[![Maintainability](https://api.codeclimate.com/v1/badges/7dbd75908417656853d7/maintainability)](https://codeclimate.com/github/story-branch/story_branch/maintainability)

# Story Branch

Story branch is a CLI application that interacts with Pivotal Tracker, Github and Jira
at the moment.

For all the trackers it supports creating local branches from the tickets or
opening the ticket in your browser from the branch you're working on. In the future
I plan to support different workflows in order to integrate your individual
process in the tool.

As for PivotalTracker, since the flow is mostly the same for everyone, it allows
you to start and un-start stories as well.


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
  story_branch configure       # Configure a new story branch configuration
  story_branch create          # Create branch from a ticket in the tracker
  story_branch finish          # Creates a git commit message for the staged changes with a [Finishes] tag
  story_branch help [COMMAND]  # Describe available commands or one specific command
  story_branch migrate         # Migrate old story branch configuration to the new format
  story_branch start           # Mark an estimated story as started in Pivotal Tracker
  story_branch unstart         # Mark a started story as un-started in Pivotal Tracker
  story_branch version         # story_branch gem version
```

## Commentary

`story_branch configure`: Step by step configuration of a new tracker for your project

### Configuration

The configuration is split into two different files: a `.story_branch.yml` in the root folder
of the project where you're configuring the tool and a `.story_branch.yml` in user's home directory.

For the management of the home directory, story_branch relies on [XDG](https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html)
specification, so if configured, it'll be installed under `~/.config` or whatever your machine
specifies.

The idea behind the two files is that the one in the root of the project should be committed to your
repository and defines basic tracker configuration settings to be shared across the contributors
to your repository. These configuration settings include the tracker type, project id in the tracker,
where you want the ticket number to be placed amongst others.

The file under your config directory is meant to be stored only locally as it will contain the api
keys needed for story branch to access your tracker. The story_branch file under your config directory
should not be published anywhere.

#### Configuring PivotalTracker

When running the command `story_branch configure` you'll be asked 3 things:
1. tracker - You should select Pivotal Tracker
2. project id - This can be fetched from the PivotalTracker url. E.g in the url `https://www.pivotaltracker.com/n/projects/651417`, the project id would be `651417`
3. api key - this is your personal api key. You can get that from [your profile page](https://www.pivotaltracker.com/profile)

#### Configuring Github

When running the command `story_branch configure` you'll be asked 3 things:
1. tracker - You should select Github
2. project id - This is the github repository name in the format `<owner>/<repo_name>`. E.g. `story-branch/story_branch`.
3. api key - this is your personal api token. You can create one under your [developer profile tokens page](https://github.com/settings/tokens)

#### Configuring JIRA

The configuration for JIRA is slightly more complex as the endpoint changes according
to your project setup. You will need an API token, which you can create a new one in your [JIRA id management page](https://id.atlassian.com/manage/api-tokens)
1. tracker - You should select JIRA
2. JIRA's subdomain - you should type the JIRA's subdomain that you use to access in your browser. E.g I'd type perxtechnologies to access to <https://perxtechnologies.atlassian.net>
3. JIRA's project key - this should match which project you want to fetch the issues from. E.g. PW is the key for my Project Whistler, so I'd type PW
4. API key that you should have gotten in the first description step
5. username used for login in the JIRA usually. If you use google email authentication, the username should be your email

#### Configuring LinearApp

When running the command `story_branch configure` you'll be asked 3 things:
1. tracker - You should select LinearApp
2. project id - This should be your team's id.
3. api key - this is your personal api token. You can create one under your [account API settings](https://linear.app/settings/api)

#### Available settings

##### Issue placement

On your local config you can add a line with `issue_placement: <Beginning|End>`.
Based on this configuration, when running `story_branch create`, the ticket id will be
used as prefix or suffix on the branch name.

E.g.
`issue_placement: Beginning`

`story_branch create` will create a branch in the format: `<issue_number>-<issue_title>`

While

`issue_placement: End`

`story_branch create` will create a branch in the format: `<issue_number>-<issue_title>`



##### Finish tag

On your local config you can add a line with `finish_tag: <Some random word>`.
This tag will be used in the commit message when running `story_branch finish`.

E.g.
`finish_tag: Resolves`

`story_branch finish` will make a commit with the message
`[Resolves #12313] story title`

### Creating a new branch following the naming convention

`story_branch create`: Creates a git branch with automatic reference to a tracker ticket.
The tickets/stories that will be fetched will depend on the project type. Once you choose the
ticket to work on, a new branch will be created based on the ticket title and id.

e.g. `my-story-name-1234567`

`story_branch finish`: Creates a git commit message for the staged changes.

e.g: `[Finishes #1234567] My story name`

You must stage all changes (or stash them) first. Note the commit will not
be pushed. Note: You'll be able to bail out of the commit.

### PivotalTracker specific commands

`story_branch start`: Start a story in Pivotal Tracker from the terminal.
It'll get all un-started stories in your current project. You can
enter text and press TAB to search for a story name, or TAB to show
the full list.

`story_branch unstart`: Un-start a story in Pivotal Tracker from the terminal.
It'll get all started stories in your current project. You can
enter text and press TAB to search for a story name, or TAB to show
the full list.

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

## Contributing

All pull requests are welcome and will be reviewed.

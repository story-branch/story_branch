# Story Branch

Story branch is a CLI application that interacts with Pivotal Tracker, Github
and JIRA.

Depending on the tracker features, it provides different approaches.

- For PivotalTracker, it allows you to start and un-start stories, as well as
creating branches based on the story name and id and have a final commit message
marking the story as Finished.

- For Github and JIRA because there is not a fixed flow, it allows you to create
the branches based on the tickets name and numbers. Similarly, it supports one
final commit with a standard message.

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
  story_branch start           # Mark an estimated story as started [Only for Pivotal Tracker]
  story_branch unstart         # Mark a started story as un-started [Only for Pivotal Tracker]
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

## Configuring PivotalTracker

When running the command `story_branch add` you'll be asked 3 things:
1. tracker - You should select Pivotal Tracker
2. project id - This can be fetched from the PivotalTracker url. E.g in the url `https://www.pivotaltracker.com/n/projects/651417`, the project id would be `651417`
3. api key - this is your personal api key. You can get that from [your profile page](https://www.pivotaltracker.com/profile)

## Configuring Github

When running the command `story_branch add` you'll be asked 3 things:
1. project id - This is the github repository name in the format `<owner>/<repo_name>`. E.g. `story-branch/story_branch`.
2. tracker - You should select Github
3. api key - this is your personal api token. You can create one under your
[developer profile tokens page](https://github.com/settings/tokens)

## Configuring JIRA

The configuration for JIRA is slightly more complex as the endpoint changes according
to your project setup. You will need an API token, which you can create a new one in your [JIRA id management page](https://id.atlassian.com/manage/api-tokens)
1. tracker - You should select JIRA
2. JIRA's subdomain - you should type the JIRA's subdomain that you use to access in your browser. E.g I'd type perxtechnologies to access to https://perxtechnologies.atlassian.net
3. JIRA's project key - this should match which project you want to fetch the issues from. E.g. PW is the key for my Project Whistler, so I'd type PW
4. API key that you should have gotten in the first description step
5. username used for login in the JIRA usually. If you use google email authentication, the username should be your email

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

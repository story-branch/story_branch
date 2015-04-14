[![Gem Version](https://badge.fury.io/rb/story_branch.png)](http://badge.fury.io/rb/story_branch)

# Story Branch

A small collection of tools for working with git branches and Pivotal
Tracker stories. `git story`, `git finish`, `git start` and `git
unstart`.

### Commentary

`git story`: Creates a git branch with automatic reference to a
Pivotal Tracker Story. It will get started stories from your active
project.  You can enter text and press TAB to search for a story
name, or TAB to show the full list. It will then suggest an editable
branch name. When the branch is created the `story_id` will
be appended to it.

e.g. `my-story-name-1234567`

`git finish`: Creates a git commit message for the staged changes.

e.g: `[Finishes #1234567] My story name`

You must stage all changes (or stash them) first. Note the commit will not
be pushed.  Note: You'll be able to bail out of the commit.

`git start`: Start a story in Pivotal Tracker from the terminal.
It'll get all unstarted stories in your current project.  You can
enter text and press TAB to search for a story name, or TAB to show
the full list.

`git unstart`: Unstart a story in Pivotal Tracker from the terminal.
It'll get all started stories in your current project.  You can
enter text and press TAB to search for a story name, or TAB to show
the full list.

### Installing

Install the gem:

    gem install story_branch

#### Settings

You must have a `PIVOTAL_API_KEY` environment variable set
to your Pivotal api key, plus either a `.story_branch` file or
`PIVOTAL_PROJECT_ID` environment variable set. Note, values in
`.story_branch` will override environment variable settings.

#### .story_branch file

A YAML file with either/both of:

    api: YOUR.PIVOTAL.API.KEY.STRING
    project: YOUR.PROJECT.ID.NUMBER

Can be saved to `~/` or `./` (ie. your project folder)

### Usage

You run story_branch from the git/project root folder.

`git story`, `git start` and `git unstart` are run interactively and
will display a list of stories to work with.

`git finish` will scan the current branch name for a story id (as its
suffix) and if a valid, active story is found on pivotal tracker it
will create a commit with a message to trigger pivotal's git
integraton features.

## Contributing

All pull requests are welcome and will be reviewed.

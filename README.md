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

You can have your settings set either on a `.story_branch` file
or in environment variables.

The `.story_branch` files have priority over environment variables so if you set both,
the configuration within `.story_branch` will be the one used.
Also, the `.story_branch` file inside a project directory has priority over the global one.

The settings will be loaded firstly from local config file, if not found then from global
config file and ultimately from the environment variables. If none are found, an error
will be thrown.

This means that you can have a globally set api key and for each project using Pivotal Tracker
have a local config inside the project folder.
E.g.

```
$ cat ~/.story_branch
api: your_API_key_that_you_get_from_pivotal_tracker

$ cat ~/your_project_dir/.story_branch
project: 123123
```

In case you prefer to use environment variables, you can set
`PIVOTAL_API_KEY` to your pivotal tracker api key and set
`PIVOTAL_PROJECT_ID` to your project id.

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

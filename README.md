[![Gem Version](https://badge.fury.io/rb/story_branch.png)](http://badge.fury.io/rb/story_branch)

# Story Branch

A small collection of tools for working with git branches for
Pivotal Tracker stories. Story branch, start, finish

### Commentary

`git story`: Create a git branch with automatic reference to a
Pivotal Tracker Story. It will get started stories from your active
project.  You can enter text and press TAB to search for a story
name, or TAB to show the full list. It will then suggest an editable
branch name. When the branch is created the `story_id` will
be appended to it.

`git start`: Start a story in Pivotal Tracker from the terminal.
It'll get all unstarted stories in your current project.  You can
enter text and press TAB to search for a story name, or TAB to show
the full list.

`git finish`: Create commit/message for the staged changes, e.g:
"[Finishes #1234567] My Story Title" - optionally Finishes the story
via pivotal tracker's api. You must stage all changes (or stash
them) first.

### Installing

Install the gem:

    gem install story_branch

**Settings:** You must have a `PIVOTAL_API_KEY` environment variable set
to your Pivotal api key, plus either a `.story_branch` file or
`PIVOTAL_PROJECT_ID` environment variable set. Note, values in
`.story_branch` will override environment variable settings.

**.story_branch file**

A YAML file with either/both of:

    api: YOUR.PIVOTAL.API.KEY.STRING
    project: YOUR.PROJECT.ID.NUMBER

Can be saved to `~/` or `./`

### Usage

You run story_branch from the git/project root folder.

`start`, `branch`, are run interactively and will display a
list of stories to work with.

`finish` will scan the current branch name for a story id (as its
suffix) and if a valid, active story is found on pivotal tracker it
will create a commit with a message to trigger pivotal's git
integraton features.

### Command names

It's possible to the commands in a few ways, we have deprecated the
old commmand names, and now encourage only the use of the `git`
style usage.

      git style  | deprecated
     ------------+--------------+--------------
      git story  | story_branch | story-branch
      git start  | story_start  | story-start
      git finish | story_finish | story-finish

## Contributing

All pull requests are welcome and will be reviewed.

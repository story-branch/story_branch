[![Gem Version](https://badge.fury.io/rb/story_branch.png)](http://badge.fury.io/rb/story_branch)

# Story Branch

## Description

A small collection of tools for working with git branches for
Pivotal Tracker stories. Story branch, story start, story finish

### Commentary

**git story**: Create a git branch with automatic reference to a
Pivotal Tracker Story, it will present a list of started stories
from your active project.  Select a story, and it will suggest a
feature branch name for that story, which you can edit or
accept. The branch will be created (the story_id will automatically
be used as a suffix in the branch name)

**git start**: Start a story in Pivotal Tracker from the terminal.
List all unstarted stories in your current project. Entering a
partial string will fuzzy match against the list.

**git finish**: Create a finishing commit + message, for example:
"[Finishes #1234567] My Story Title" - optionally Finishes the story
via pivotal tracker's api.

### Installing

Install the gem:

    gem install story_branch

You must have a `PIVOTAL_API_KEY` environment variable set to your
Pivotal api key, plus either a `.story_branch` file or
`PIVOTAL_PROJECT_ID` environment variable set. Note, values in
`.story_branch` will override environment variable settings.

### Usage

Note: Run story_branch from the project root folder.

`start`, `story`, are run interactively and will display a
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

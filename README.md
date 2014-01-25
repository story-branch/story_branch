# Story Branch

Create a git feature branch with automatic reference to a Pivotal Tracker Story

By default `story_branch` will present a list of started stories from
your PivotalTracker project (set by `.pivotal-id` file or
`PIVOTAL_PROJECT_ID` environment var), you select one and then provide
a feature branch name for that story. The branch will be created and
the name will include the story_id as a suffix.

When picking a story, enter the selection number on the left, using up
arrow (or C-p) will scroll through the selection numbers.

Once a story is selected, a feature branch name can be entered, a
suggestion is shown if you press the up arrow (or C-p)

The feature branch name input has full
[Readline](http://tiswww.case.edu/php/chet/readline/rluserman.html#SEC5)
capability, to make it easy and pleasant to edit.

(P.S. I'd recommend setting a git alias of "git story" to run this
script)

For the moment, this is just a dirty little implementation.  It will
be improved / cleaned and wrapped in thor, and published as a gem, in
due course.

## Setup

This is a terminal only utility, it will work with anything that
supports running a ruby script. (Ruby 1.9.3+ but we recommend 2.x up)

First make sure you have the gems listed below installed, run `bundle`
in the same folder as `story_branch`

Grab your Pivotal Tracker API key and place it in your .bashrc (or
.zshrc etc.) as:

    export PIVOTAL_API_KEY=yourapikeywithoutquotesoranythingelse

You also can run that line on it's own, so you don't have to open a
new shell. The API key is visble at the bottom of your Pivotal Tracker
Profile page when you're logged in.

To identify which Pivotal Project to use, place a `.pivotal-id` file
in the project root folder, alongside `.git` and `.gitignore` etc.

`.pivotal-id` should just contain the id number of the project. Find
it at the end of the project page url, it's the number after the last
`/`. There's an example `.pivotal-id` in the repository.

You can also use the environment var `PIVOTAL_PROJECT_ID` if you
prefer.

## Usage

Once you're setup, place `story_branch` in your path.

Navigate to your project root, and while it's checked out at your
master branch, type:

    story_branch

Follow the directions on screen. When the process is finished,
you'll be switched automatically to the newly created branch.

## Dependencies

The following gems were used to build this. Along with Readline (which
is in the Ruby stdlib, you should also use it, really.)

* Pivotal Tracker - http://github.com/
* Ruby Git - https://github.com/schacon/ruby-git
* Levenshtein-ffi - http://rubydoc.info/gems/levenshtein-ffi/1.0.3/frames

## Changelog

* Provide readline editing for inputs
* Present safe version of story name (dash-cased) for editing
** Readline history injection for story selection & branch name suggestion
* Validate that branchname is 'legal'
* Validate that branchname doesn't already exist (strip pivotal
  tracker ids suffix from existing names when present)
* Use Levenshtein Distance to determine if name is (very) similar to
  existing branch names
* Use Git gem
* Use ActiveSupport gem
* Use Levenschtein-ffi gem
* Look for pivotal project id (.pivotal-id) in repo root (we assume
  we're in project root.) fallback to `PIVOTAL_PROJECT_ID` environment
  var

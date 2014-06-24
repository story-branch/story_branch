[![Gem Version](https://badge.fury.io/rb/story_branch.png)](http://badge.fury.io/rb/story_branch)

# Story Branch

Create a git feature branch with automatic reference to a Pivotal Tracker Story

By default `story_branch` will present a list of started stories from
your Pivotal Tracker project, you select one and then provide
a feature branch name for that story. The branch will be created and
the name will include the selected `story_id` as a suffix.

When picking a story, enter the selection number on the left, using the up
arrow (or C-p) will scroll through the selection numbers.

Once a story is selected, a feature branch name can be entered, a
suggestion is provided (press the up arrow (or C-p) to see it)

The feature branch name input has full
[Readline](http://tiswww.case.edu/php/chet/readline/rluserman.html#SEC5)
capability, to make it easy and pleasant to edit.

## Setup

Install the gem:

    gem install story_branch

Config the Pivotal API key and Project ID, either in the environment
or using a config YAML file. (`.story_branch` in the git root, or
`~/.story_branch`)

The environment variables to set are `PIVOTAL_API_KEY` and `PIVOTAL_PROJECT_ID`

The **Pivotal API** key is visble at the bottom of your Pivotal Tracker
Profile page when you're logged in. the **Project ID** is in the URL for
your pivotal project.

If you decide to use the `.story_branch` config file, it should look
something like:

    project: 123456
    api: REHTKHMYKEYISM328974Y32487AND_SO_ON

Or just:

    project: 123456

Replace the values with your own. Any value not found in the config
will attempt to be set from the environment. An error is thrown for a
value that cannot be found anywhere.

Note, that only one config file will be used at the moment, values
**CANNOT** currently be split over `.story_branch` in the git root and
`~/.story_branch`

## Usage

While checked out at your master branch, and located in the git root.

    story_branch

Follow the directions on screen. When the process is finished, you'll
be switched automatically to the newly created branch.

## Aliases

You can also run story branch using the following aliases.

    git story

    git story-branch

    story-branch


## Roadmap

Prepare a v1.0 release

## Changelog

* Banish constraint of master as parent branch
* Verify API key / Project ID
* Update config method to use YAML .story_branch files (in git root or $HOME) see above.
* Build/Publish as Ruby gem
* Simple sanitization
* Begin test coverage
* Refactor to class
* Provide readline editing for inputs
* Present safe version of story name (dash-cased) for editing
* Readline history injection for story selection & branch name suggestion
* Validate that branchname is 'legal'
* Validate that branchname doesn't already exist (strip pivotal
  tracker ids suffix from existing names when present)
* Use Levenshtein Distance to determine if name is (very) similar to
  existing branch names
* Use Git gem
* Use ActiveSupport gem
* Use Levenschtein-ffi gem
* ~~Look for pivotal project id (.pivotal-id) in repo root (we assume
  we're in project root.) fallback to `PIVOTAL_PROJECT_ID` environment
  var~~ **PLEASE NOTE:** Now uses `.story_branch` or `~/.story_branch`
  as config file, containing YAML. Only one is used, the local root
  `.story_branch` is favoured.

## Contributing

If you'd like to contribute to `story_branch` please follow the steps below.

* Fork, start a feature branch and check it out
* Write tests / Pass them
* Send a pull request

**Note:** Pull requests require full test coverage to be accepted.

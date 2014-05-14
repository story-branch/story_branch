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
be switched automatically to the newly created branch. If you aren't
checked out on **master** `story_branch` will throw an error.

## Roadmap

* Allow usage of both `.story_branch` and `~/.story_branch` to store
  different keys, favor local root `.story_branch` for values
* Interactive checkout to `master` if in another branch
* Optional pivotal story type Prefix for branch
  name. `["feature/", "bugfix/", "chore/"]` set by config.
* More advanced sanitization of branch names (TBC)

## Changelog

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

**Note:** Acceptible PR's will require full test coverage.

## Licence

Copyright (c) Jason Milkins, Rui Baltazar & Gabe Hollombe

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

The second option is to modify it slightly, as shown in the examples below:

Modified versions of the license

The license can be modified to suit particular needs. For example, the Free Software Foundation agreed in 1998 to use a modified MIT License for ncurses, which adds this clause:[4]

Except as contained in this notice, the name(s) of the above copyright holders shall not be used in advertising or otherwise to promote the sale, use or other dealings in this Software without prior written authorization.
The XFree86 Project uses a modified MIT License for XFree86 version 4.4 onward. The license includes a clause that requires attribution in software documentation.[5] The Free Software Foundation contends that this addition is incompatible with the version 2 of the GPL, but compatible with version 3.[6]

The end-user documentation included with the redistribution, if any, must include the following acknowledgment: "This product includes software developed by The XFree86 Project, Inc (http://www.xfree86.org/) and its contributors", in the same place and form as other third-party acknowledgments. Alternately, this acknowledgment may appear in the software itself, in the same form and location as other such third-party acknowledgments.
The source of information for the modified licenses is http://en.wikipedia.org/wiki/MIT_License

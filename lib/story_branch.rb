# Name: story branch
#
# Authors: Jason Milkins <jason@opsmanager.com>
#          Rui Baltazar <rui.p.baltazar@gmail.com>
#          Dominic Wong <dominic.wong.617@gmail.com>
#          Ranhiru Cooray <ranhiru@gmail.com>
#          Gabe Hollombe <gabe@neo.com>
#
# Version: 0.2.9
#
# ## Description
# A small collection of tools for working with git branches and Pivotal
# Tracker stories. `git story`, `git finish`, `git start` and `git
# unstart`.
#
# ### Commentary
#
# `git story`: Creates a git branch with automatic reference to a
# Pivotal Tracker Story. It will get started stories from your active
# project.  You can enter text and press TAB to search for a story
# name, or TAB to show the full list. It will then suggest an editable
# branch name. When the branch is created the `story_id` will
# be appended to it.
#
# e.g. `my-story-name-1234567`
#
# `git finish`: Creates a git commit message for the staged changes.
#
# e.g: `[Finishes #1234567] My story name`
#
# You must stage all changes (or stash them) first. Note the commit will not
# be pushed.  Note: You'll be able to bail out of the commit.
#
# `git start`: Start a story in Pivotal Tracker from the terminal.
# It'll get all unstarted stories in your current project.  You can
# enter text and press TAB to search for a story name, or TAB to show
# the full list.
#
# `git unstart`: Unstart a story in Pivotal Tracker from the terminal.
# It'll get all started stories in your current project.  You can
# enter text and press TAB to search for a story name, or TAB to show
# the full list.
#
# ### Installing
#
# Install the gem:
#
#     gem install story_branch
#
# #### Settings
#
# You must have a `PIVOTAL_API_KEY` environment variable set
# to your Pivotal api key, plus either a `.story_branch` file or
# `PIVOTAL_PROJECT_ID` environment variable set. Note, values in
# `.story_branch` will override environment variable settings.
#
# #### .story_branch file
#
# A YAML file with either/both of:
#
#     api: YOUR.PIVOTAL.API.KEY.STRING
#     project: YOUR.PROJECT.ID.NUMBER
#
# Can be saved to `~/` or `./` (ie. your project folder)
#
# ### Usage
#
# You run story_branch from the git/project root folder.
#
# `git story`, `git start` and `git unstart` are run interactively and
# will display a list of stories to work with.
#
# `git finish` will scan the current branch name for a story id (as its
# suffix) and if a valid, active story is found on pivotal tracker it
# will create a commit with a message to trigger pivotal's git
# integraton features.
#
# ## Contributing
#
# All pull requests are welcome and will be reviewed.
#
# Code:

require 'byebug'
require 'yaml'
require 'blanket'
require 'rb-readline'
require 'readline'
require 'git'
require 'levenshtein'

trap('INT') { exit }

module StoryBranch
  class Main
    ERRORS = {
      'Stories in the started state must be estimated.' =>
      "Error: Pivotal won't allow you to start an unestimated story"
    }

    PIVOTAL_CONFIG_FILES = ['.story_branch', "#{ENV['HOME']}/.story_branch"]

    attr_accessor :p

    def initialize
      @p = PivotalUtils.new
      @p.api_key = config_value 'api', 'PIVOTAL_API_KEY'
      @p.project_id = config_value 'project', 'PIVOTAL_PROJECT_ID'
      exit unless @p.valid?
    end

    def unauthorised_message
      $stderr.puts 'Pivotal API key or Project ID invalid'
    end

    def create_story_branch
      begin
        puts 'Connecting with Pivotal Tracker'
        @p.get_project
        puts 'Getting stories...'
        stories = @p.display_stories :started, false
        if stories.length < 1
          puts 'No stories started, exiting'
          exit
        end
        story = @p.select_story stories
        if story
          @p.create_feature_branch story
        end
      rescue Blanket::Unauthorized
        unauthorised_message
        return nil
      end
    end

    def pick_and_update filter, hash, msg, is_estimated
      begin
        puts 'Connecting with Pivotal Tracker'
        @p.get_project
        puts 'Getting stories...'
        stories = @p.filtered_stories_list filter, is_estimated
        story = @p.select_story stories
        if story
          result = @p.story_update story, hash
          fail result.error if result.error
          puts "#{story.id} #{msg}"
        end
      rescue Blanket::Unauthorized
        unauthorised_message
        return nil
      end
    end

    def story_start
      pick_and_update(:unstarted, { current_state: 'started' }, 'started', true)
    end

    def story_unstart
      pick_and_update(:started, { current_state: 'unstarted' }, 'unstarted', false)
    end

    def story_estimate
      # TODO: estimate a story
    end

    def story_finish
      begin
        puts 'Connecting with Pivotal Tracker'
        @p.get_project

        unless @p.is_current_branch_a_story?
          puts "Your current branch: '#{GitUtils.current_branch}' is not linked to a Pivotal Tracker story."
          return nil
        end

        if GitUtils.has_status? :untracked or GitUtils.has_status? :modified
          puts 'There are unstaged changes'
          puts 'Use git add to stage changes before running git finish'
          puts 'Use git stash if you want to hide changes for this commit'
          return nil
        end

        unless GitUtils.has_status? :added or GitUtils.has_status? :staged
          puts 'There are no staged changes.'
          puts 'Nothing to do'
          return nil
        end

        puts 'Use standard finishing commit message: [y/N]?'
        commit_message = "[Finishes ##{GitUtils.current_branch_story_parts[:id]}] #{StringUtils.undashed GitUtils.current_branch_story_parts[:title]}"
        puts commit_message

        if gets.chomp!.downcase == 'y'
          GitUtils.commit commit_message
        else
          puts 'Aborted'
        end
      rescue Blanket::Unauthorized
        unauthorised_message
        return nil
      end
    end

    def config_value key, env
      PIVOTAL_CONFIG_FILES.each do |config_file|
        if File.exists? config_file
          pivotal_info = YAML.load_file config_file
          return pivotal_info[key] if pivotal_info[key]
        end
      end
      value ||= env_required env
      value
    end

    def env_required var_name
      if ENV[var_name].nil?
        $stderr.puts "$#{var_name} must be set or in .story_branch file"
        return nil
      end
      ENV[var_name]
    end

  end

  class StringUtils

    def self.dashed s
      s.tr(' _,./:;+&', '-')
    end

    def self.simple_sanitize s
      strip_newlines (s.tr '\'"%!@#$(){}[]*\\?', '')
    end

    def self.normalised_branch_name s
      simple_sanitize((dashed s).downcase).squeeze('-')
    end

    def self.strip_newlines s
      s.tr "\n", '-'
    end

    def self.undashed s
      s.gsub(/-/, ' ').capitalize
    end

  end

  class GitUtils
    def self.g
      Git.open '.'
    end

    def self.is_existing_branch? name
      branch_names.each do |n|
        if Levenshtein.distance(n, name) < 3
          return true
        end
        existing_branch_name = n.match(/(.*)(-[1-9][0-9]+$)/)
        if existing_branch_name
          levenshtein_distance = Levenshtein.distance existing_branch_name[1], name
          if levenshtein_distance < 3
            return true
          end
        end
      end
      return false
    end

    def self.is_existing_story? id
      branch_names.each do |n|
        branch_id = n.match(/-[1-9][0-9]+$/)
        if branch_id
          if branch_id.to_s == "-#{id}"
            return true
          end
        end
      end
      false
    end

    def self.branch_names
      g.branches.map(&:name)
    end

    def self.current_branch
      g.current_branch
    end

    def self.current_story
      current_branch.match(/(.*)-(\d+$)/)
    end

    def self.current_branch_story_parts
      matches = current_story
      if matches.length == 3
        { title: matches[1], id: matches[2] }
      else
        nil
      end
    end

    def self.create_branch name
      g.branch(name).create
      g.branch(name).checkout
    end

    def self.status_collect status, regex
      status.select{|e|
        e.match(regex)
      }.map{|e|
        e.match(regex)[1]
      }
    end

    def self.status
      modified_rx  = /^ M (.*)/
      untracked_rx = /^\?\? (.*)/
      staged_rx    = /^M  (.*)/
      added_rx     = /^A  (.*)/
      status = g.lib.send(:command, 'status', '-s').lines
      return nil if status.length == 0
      {
        modified:  status_collect(status, modified_rx),
        untracked: status_collect(status, untracked_rx),
        added:     status_collect(status, added_rx),
        staged:    status_collect(status, staged_rx)
      }
    end

    def self.has_status? state
      return false unless status
      status[state].length > 0
    end

    def self.commit message
      g.commit(message)
    end

  end

  class PivotalUtils
    API_URL = 'https://www.pivotaltracker.com/services/v5/'
    attr_accessor :api_key, :project_id

    def valid?
      !@api_key.nil? && !@project_id.nil?
    end

    def api
      fail 'API key must be specified' unless @api_key
      Blanket.wrap API_URL, headers: { 'X-TrackerToken' => @api_key }
    end

    def get_project
      fail 'Project ID must be set' unless @project_id
      api.projects(@project_id.to_i)
    end

    def story_accessor
      get_project.stories
    end

    def is_current_branch_a_story?
      GitUtils.current_story and
        GitUtils.current_story.length == 3 and
        filtered_stories_list(:started, true)
        .map(&:id)
        .include? GitUtils.current_story[2].to_i
    end

    def story_from_current_branch
      story_accessor.get(GitUtils.current_story[2].to_i) if GitUtils.current_story.length == 3
    end

    # TODO: Maybe add some other predicates
    # - Filtering on where a story lives (Backlog, IceBox)
    # - Filtering on labels
    # as the need arises...
    #
    def filtered_stories_list state, estimated
      options = { with_state: state.to_s }
      stories = [* story_accessor.get(params: options).payload]
      if estimated
        stories.select do |s|
          s.story_type == 'bug' || s.story_type == 'chore' ||
            (s.story_type == 'feature' && s.estimate && s.estimate >= 0)
        end
      else
        stories
      end
    end

    def display_stories state, estimated
      filtered_stories_list(state, estimated).each {|s| puts one_line_story s }
    end

    def one_line_story s
      "#{s.id} - #{s.name}"
    end

    def select_story stories
      story_texts = stories.map{|s| one_line_story s }
      puts 'Leave blank to exit, use <up>/<down> to scroll through stories, TAB to list all and auto-complete'
      story_selection = readline('Select a story: ', story_texts)
      return nil if story_selection == '' or story_selection.nil?
      story = stories.select{|s| story_matcher s, story_selection }.first
      if story.nil?
        puts "Not found: #{story_selection}"
        return nil
      else
        puts "Selected : #{one_line_story story}"
        return story
      end
    end

    def story_update story, hash
      get_project.stories(story.id).put(body: hash).payload
    end

    def story_matcher story, selection
      m = selection.match(/^(\d*) /)
      return false unless m
      id = m.captures.first
      return story.id.to_s == id
    end

    def create_feature_branch story
      dashed_story_name = StringUtils.normalised_branch_name story.name
      feature_branch_name = nil
      puts "You are checked out at: #{GitUtils.current_branch}"
      while feature_branch_name == nil or feature_branch_name == ''
        puts 'Provide a new branch name... (TAB for suggested name)' if [nil, ''].include? feature_branch_name
        feature_branch_name = readline('Name of feature branch: ', [dashed_story_name])
      end
      feature_branch_name.chomp!
      if validate_branch_name feature_branch_name, story.id
        feature_branch_name_with_story_id = "#{feature_branch_name}-#{story.id}"
        puts "Creating: #{feature_branch_name_with_story_id} with #{GitUtils.current_branch} as parent"
        GitUtils.create_branch feature_branch_name_with_story_id
      end
    end

    # Branch name validation
    def validate_branch_name name, id
      if GitUtils.is_existing_story? id
        puts "Error: An existing branch has the same story id: #{id}"
        return false
      end
      if GitUtils.is_existing_branch? name
        puts 'Error: This name is very similar to an existing branch. Avoid confusion and use a more unique name.'
        return false
      end
      unless valid_branch_name? name
        puts "Error: #{name}\nis an invalid name."
        return false
      end
      true
    end

    def valid_branch_name? name
      # Valid names begin with a letter and are followed by alphanumeric
      # with _ . - as allowed punctuation
      valid = /[a-zA-Z][-._0-9a-zA-Z]*/
      name.match valid
    end

    def readline prompt, completions=[]
      # Store the state of the terminal
      RbReadline.clear_history
      if completions.length > 0
        completions.each {|i| Readline::HISTORY.push i}
        RbReadline.rl_completer_word_break_characters = ''
        Readline.completion_proc = proc { |s| completions.grep(/#{Regexp.escape(s)}/) }
        Readline.completion_append_character = ''
      end
      Readline.readline(prompt, false)
    end
  end
end

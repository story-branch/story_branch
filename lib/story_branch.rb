# Name: story branch
#
# Authors: Jason Milkins <jason@opsmanager.com>
#          Rui Baltazar <rui.p.baltazar@gmail.com>
#          Dominic Wong <dominic.wong.617@gmail.com>
#          Gabe Hollombe <gabe@neo.com>
#
# Version: 0.2.0
#
# ## Description
#
# A small collection of tools for working with git branches for
# Pivotal Tracker stories. Story branch, start, finish
#
# ### Commentary
#
# **branch**: Create a git branch with automatic reference to a
# Pivotal Tracker Story, it will present a list of started stories
# from your active project.  Select a story, and it will suggest a
# feature branch name for that story, which you can edit or
# accept. The branch will be created (the story_id will automatically
# be used as a suffix in the branch name)
#
# **start**: Start a story in Pivotal Tracker from the terminal.
# List all unstarted stories in your current project. Entering a
# partial string will fuzzy match against the list.
#
# **finish**: Create a finishing commit + message, for example:
# "[Finishes #1234567] My Story Title" - optionally Finishes the story
# via pivotal tracker's api.
#
# ### Installing
#
# Install the gem:
#
#     gem install story_branch
#
# You must have a `PIVOTAL_API_KEY` environment variable set to your
# Pivotal api key, plus either a `.story_branch` file or
# `PIVOTAL_PROJECT_ID` environment variable set. Note, values in
# `.story_branch` will override environment variable settings.
#
# ### Usage
#
# Note: Run story_branch from the project root folder.
#
# `start`, `branch`, are run interactively and will display a
# list of stories to work with.
#
# `finish` will scan the current branch name for a story id (as its
# suffix) and if a valid, active story is found on pivotal tracker it
# will create a commit with a message to trigger pivotal's git
# integraton features.
#
# ### Command names
#
# It's possible to the commands in a few ways, we have deprecated the
# old commmand names, and now encourage only the use of the `git`
# style usage.
#
#       git style  | deprecated
#      ------------+--------------+--------------
#       git story  | story_branch | story-branch
#       git start  | story_start  | story-start
#       git finish | story_finish | story-finish
#
# ## Contributing
#
# All pull requests are welcome and will be reviewed.
#
# Code:

require 'yaml'
require 'pivotal-tracker'
require 'readline'
require 'git'
require 'active_support/core_ext/string/inflections'
require 'levenshtein'

module StoryBranch

  class Main

    PIVOTAL_CONFIG_FILES = ['.story_branch',"#{ENV['HOME']}/.story_branch"]

    attr_accessor :p

    def initialize
      if config_file
        @pivotal_info = YAML.load_file config_file
      end
      @p            = PivotalUtils.new
      @p.api_key    = config_value "api", 'PIVOTAL_API_KEY'
      @p.project_id = config_value "project", 'PIVOTAL_PROJECT_ID'
      exit unless @p.valid?
    end

    def create_story_branch
      begin
        @p.get_project
        stories = @p.display_stories :started
        if stories.length < 1
          puts "No stories started... exiting"
          exit
        end
        puts "[0] Exit"
        story   = @p.select_story stories
        if story
          @p.create_feature_branch story
        end
      rescue RestClient::Unauthorized
        puts "Pivotal API key or Project ID invalid"
        return nil
      end
    end

    def story_start
      begin
        @p.get_project
        # TODO: Use a predicate for Estimated and Backlog'ed stories
        stories = @p.display_stories :unstarted
        puts "[0] Exit"
        story = @p.select_story stories
        if story
          story.update :current_state => "started"
          puts "#{story.id} started"
        end
      rescue RestClient::Unauthorized
        puts "Pivotal API key or Project ID invalid"
        return nil
      end
    end

    def story_unstart
      # TODO: unstart a started story.
    end

    def story_finish
      begin
        @p.get_project
        unless @p.is_current_branch_a_story?
          puts "Your current branch: #{GitUtils.current_branch}"
          puts "is not linked to a started story."
          return
        end

        if GitUtils.has_status? :untracked or GitUtils.has_status? :modified
          puts "There are unstaged changes"
          puts "Use git add to stage changes before running git finish"
          puts "Use git stash if you want to hide changes for this commit"
          return
        end

        unless GitUtils.has_status? :added or GitUtils.has_status? :staged
          puts "There are no staged changes."
          puts "Nothing to do"
          return
        end

        puts "Use standard finishing commit message: [y/N]?"
        commit_message = "[Finishes ##{GitUtils.current_branch_story_parts[:id]}] #{GitUtils.current_branch_story_parts[:description]}"
        puts commit_message

        if gets.chomp!.downcase == "y"
          GitUtils.commit commit_message
        else
          puts "Aborted"
        end
      rescue RestClient::Unauthorized
        puts "Pivotal API key or Project ID invalid"
        return nil
      end
    end

    def config_file
      PIVOTAL_CONFIG_FILES.select{|conf| File.exists? conf}.first
    end

    def config_value key, env
      value = @pivotal_info[key] if @pivotal_info and @pivotal_info[key]
      value ||= env_required env
      value
    end

    def env_required var_name
      if ENV[var_name].nil?
        puts "$#{var_name} must be set or in .story_branch file"
        return nil
      end
      ENV[var_name]
    end

  end

  class StringUtils

    def self.dashed s
      s.tr(' _,./:;', '-')
    end

    def self.simple_sanitize s
      s.tr '\'"%!@#$(){}[]*\\?', ''
    end

  end

  class GitUtils

    def self.g
      Git.open "."
    end

    def self.is_existing_branch? name
      # we don't use the Git gem's is_local_branch? because we want to
      # ignore the id suffix while still avoiding name collisions
      branch_names.each do |n|
        normalised_branch_name = StringUtils.simple_sanitize(StringUtils.dashed(n.match(/(^.*)(-[1-9][0-9]+$)?/)[1]))
        levenshtein_distance = Levenshtein.distance normalised_branch_name, name
        if levenshtein_distance < 2
          return levenshtein_distance
        end
      end
      return -1
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
      matches = current_branch.match(/(.*)-(\d+$)/)
      if matches.length == 3
        { description: matches[1], id: matches[2] }
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
      status = g.lib.send(:command, "status", "-s").lines
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

    attr_accessor :api_key, :project_id, :project

    def valid?
      return (not @api_key.nil? and not @project_id.nil?)
    end

    def get_project
      PivotalTracker::Client.token = @api_key
      @project = PivotalTracker::Project.find @project_id.to_i
    end

    def is_current_branch_a_story?
      GitUtils.current_story.length == 3 and
        filtered_stories_list(:started).map(&:id).include? GitUtils.current_story[2].to_i
    end

    def story_from_current_branch
      get_project.stories.find(GitUtils.current_story[2].to_i) if GitUtils.current_story.length == 3
    end

    # TODO: Add some other predicates as we need them...
    # Filtering on where a story lives (Backlog, IceBox)
    # Filtering on tags/labels
    # Filtering on estimation (estimated?, 0 point, 1 point etc.)

    def filtered_stories_list state
      project = get_project
      project.stories.all({current_state: state})
    end

    def display_stories state
      filtered_stories_list(state).each_with_index {|s,i| puts one_line_story s, i}
    end

    def one_line_story s, i
      "[#{i+1}] ##{s.id} : #{s.name}"
    end

    def select_story stories
      story_selection = nil
      while story_selection == nil or story_selection.to_i > stories.length + 1
        puts "invalid selection" if story_selection != nil
        story_texts = Range.new(1,stories.length).to_a.map(&:to_s)
        story_selection = readline("Select a story: ", story_texts)
      end
      if story_selection.to_i == 0
        return nil
      end
      story = stories[story_selection.to_i - 1]
      puts "Selected : ##{story.id} : #{story.name}"
      return story
    end

    def create_feature_branch story
      dashed_story_name = StringUtils.simple_sanitize((StringUtils.dashed story.name).downcase).squeeze("-")
      feature_branch_name = nil
      puts "You are checked out at: #{GitUtils.current_branch}"
      while feature_branch_name == nil or feature_branch_name == ""
        puts "Provide a new branch name... (C-p or <up> for suggested name)" if [nil, ""].include? feature_branch_name
        feature_branch_name = readline("Name of feature branch: ", [dashed_story_name])
      end
      feature_branch_name.chomp!
      validate_branch_name feature_branch_name
      feature_branch_name_with_story_id = "#{feature_branch_name}-#{story.id}"
      puts "Creating: #{feature_branch_name_with_story_id} with #{GitUtils.current_branch} as parent"
      GitUtils.create_branch feature_branch_name_with_story_id
    end

    # Branch name validation
    def validate_branch_name name
      unless valid_branch_name? name
        puts "Error: #{name}\nis an invalid name."
        return false
      end
      existing_name_score = GitUtils.is_existing_branch?(name)
      unless existing_name_score == -1
        puts <<-END.strip_heredoc
        Name Collision Error:

        #{name}

        This is too similar to the name of an existing
        branch, a more unique name is required
      END
      end
    end

    def valid_branch_name? name
      # Valid names begin with a letter and are followed by alphanumeric
      # with _ . - as allowed punctuation
      valid = /[a-zA-Z][-._0-9a-zA-Z]*/
      name.match valid
    end

    def readline prompt, history=[]
      if history.length > 0
        history.each {|i| Readline::HISTORY.push i}
      end
      begin
        Readline.readline(prompt, false)
      rescue Interrupt
      end
    end

  end
end

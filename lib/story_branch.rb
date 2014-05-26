# Name: story_branch (recommend: setting a git alias as "git story")
#
# Authors: Jason Milkins <jason@opsmanager.com>
#          Rui Baltazar <rui.p.baltazar@gmail.com>
#          Gabe Hollombe <gabe@neo.com>
#          Dominic Wong <dominic.wong.617@gmail.com>
#
# Version: 0.1.5
#
# Description:
#
# Create a git branch with automatic reference to a Pivotal Tracker
# Story ID
#
# Commentary:
#
# By default story_branch will present a list of started stories from
# your active PivotalTracker project, you select one and then provide
# a feature branch name for that story. The branch will be created and
# the name will include the story_id as a suffix.
#
# When picking a story, enter the selection number on the left (up
# arrow / C-p will scroll through the numbers)
#
# Once a story is selected, a feature branch name must be entered, a
# suggestion is shown if you press up arrow / C-p
#
# Usage:
#
# Note: Run story_branch from the project root folder, with the
# master branch checked out, or an error will be thrown.
#
# You must have a PIVOTAL_API_KEY environment variable set to your
# Pivotal api key, and either a .pivotal-id file or PIVOTAL_PROJECT_ID
# environment variable set, (the file will supersede the environment
# variable)
#

require 'yaml'
require 'pivotal-tracker'
require 'readline'
require 'git'
require 'levenshtein'

class StoryBranch

  # Config file = .pivotal or ~/.pivotal
  # contains YAML
  # project: pivotal-id
  # api: pivotal api key

  # NOTE: Is this Windows friendly? Await freak-outs from those users... *crickets*
  PIVOTAL_CONFIG_FILES = ['.story_branch',"#{ENV['HOME']}/.story_branch"]

  def initialize
    if config_file
      @pivotal_info = YAML.load_file config_file
    end

    @api_key = config_value "api", 'PIVOTAL_API_KEY'
    @project_id = config_value "project", 'PIVOTAL_PROJECT_ID'
  end

  def config_file
    PIVOTAL_CONFIG_FILES.select{|conf| File.exists? conf}.first
  end

  def config_value key, env
    value = @pivotal_info[key] if @pivotal_info and @pivotal_info[key]
    value ||= env_required env
    value
  end

  def connect
    begin
      pivotal_story_branch @api_key, @project_id
    rescue RestClient::Unauthorized
      puts "Pivotal API key or Project ID invalid"
      exit
    end
  end

  def valid?
    return (not @api_key.strip.empty? and not @project_id.strip.empty?)
  end

  private
  def env_required var_name
    if ENV[var_name].nil?
      puts "$#{var_name} must be set or in .story_branch file"
      exit
    end
    ENV[var_name]
  end

  def readline prompt, history=[]
    if history.length > 0
      history.each {|i| Readline::HISTORY.push i}
    end
    begin
      Readline.readline(prompt, false)
    rescue Interrupt
      exit
    end
  end

  def dashed s
    s.tr(' _,./:;', '-')
  end

  def simple_sanitize s
    s.tr '\'"%!@#$(){}[]*\\?', ''
  end

  # Branch name validation
  def validate_branch_name name
    unless valid_branch_name? name
      puts "Error: #{name}\nis an invalid name."
      return false
    end
    existing_name_score = is_existing_branch?(name)
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

  # Git operations

  def is_existing_branch? name
    # we don't use the Git gem's is_local_branch? because we want to
    # ignore the id suffix while still avoiding name collisions
    git_branch_names.each do |n|
      normalised_branch_name = simple_sanitize(dashed(n.match(/(^.*)(-[1-9][0-9]+$)?/)[1]))
      levenshtein_distance = Levenshtein.distance normalised_branch_name, name
      if levenshtein_distance < 2
        return levenshtein_distance
      end
    end
    return -1
  end

  def git_branch_names
    g = Git.open "."
    g.branches.map(&:name)
  end

  def git_current_branch
    g = Git.open "."
    g.current_branch
  end

  def git_create_branch name
    g = Git.open "."
    g.branch(name).create
    g.branch(name).checkout
  end

  # Use Pivotal tracker API to get Stories

  def list_pivotal_stories api_key, project_id
    PivotalTracker::Client.token = api_key
    project = PivotalTracker::Project.find(project_id.to_i)
    stories = project.stories.all({current_state: :started})
    stories.each_with_index{|s,i| puts "[#{i+1}] ##{s.id} : #{s.name}"}
    stories
  end

  def select_story stories
    story_selection = nil
    while story_selection == nil or story_selection == 0 or story_selection > stories.length + 1
      puts "invalid selection" if story_selection != nil
      story_selection = readline("Select a story: ", Range.new(1,stories.length).to_a.map(&:to_s)).to_i
    end
    story = stories[story_selection - 1]
    puts "Selected : ##{story.id} : #{story.name}"
    return story
  end

  def create_feature_branch story
    current_branch = git_current_branch
    dashed_story_name = simple_sanitize((dashed story.name).downcase).squeeze("-")
    feature_branch_name = nil
    puts "You are checked out at: #{current_branch}"
    if current_branch == "master"
      while feature_branch_name == nil or feature_branch_name == ""
        puts "Provide a new branch name..." if [nil, ""].include? feature_branch_name
        feature_branch_name = readline("Name of feature branch: ", [dashed_story_name])
      end
      feature_branch_name.chomp!
      validate_branch_name feature_branch_name
      feature_branch_name_with_story_id = "#{feature_branch_name}-#{story.id}"
      puts "Creating: #{feature_branch_name_with_story_id}"
      git_create_branch feature_branch_name_with_story_id
    else
      puts "Feature branches must be created from 'master'"
    end
  end

  def pivotal_story_branch api_key, project_id
    stories = list_pivotal_stories api_key, project_id
    story = select_story stories
    create_feature_branch story
  end
end

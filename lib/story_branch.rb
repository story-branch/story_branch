# Name: story_branch (recommend: setting a git alias as "git story")
#
# Author: Jason Milkins <jason@opsmanager.com> & Gabe Hollombe <gabe@neo.com>
#
# Description:
#
# Create a git branch with automatic reference to a Pivotal Tracker Story ID
#
# Commentary:
#
# By default story_branch will present a list of started
# stories from your active PivotalTracker project, you select one and
# then provide a feature branch name for that story. The branch will
# be created and the name will include the story_id as a suffix.
#
# When picking a story, enter the selection number on the left (up
# arrow / C-p will scroll through the numbers)
#
# Once a story is selected, a feature branch name must be entered, a
# suggestion is shown if you press up arrow / C-p
#
# Changelog:
#
# Milestone 'porus-flapjack' DONE
# * Present safe version of story name (dash-cased) for editing
# * Provide readline editing
#
# Milestone 'eggs-n-bakey' DONE
# * Validate that branchname is 'legal'
# * Validate that branchname doesn't already exist (strip pivotal
#   tracker ids suffix from existing names when present)
# * Use Levenshtein Distance to determine if name is (very) similar to
#   existing branch names
# * Use Git gem
# * Use ActiveSupport gem
# * Use Levenschtein-ffi gem
# * Readline history injection for story selection & branch name suggestion
#
# Milestone 'tequila-grizzly' DONE
# * Look for pivotal project id (.pivotal-id) in repo root (we assume
#   we're in project root.) (before checking environment)
#
# Backlog:
# ...

require 'pivotal-tracker'
require 'readline'
require 'git'
require 'levenshtein-ffi'

class StoryBranch

  def initialize
    @api_key = File.read(".pivotal_api_key") rescue env_required('PIVOTAL_API_KEY')
    raise "Existing .pivotal_api_key config file found, but without contents" unless not @api_key.empty?
    @project_id = File.read(".pivotal_project_id") rescue env_required('PIVOTAL_PROJECT_ID')
    raise "Existing .pivotal_project_id config file found, but without contents" unless not @project_id.empty?
  end

  def connect
    pivotal_story_branch @api_key, @project_id
  end

  def valid?
    return (not @api_key.strip.empty? and not @project_id.strip.empty?)
  end
  
  private
  def env_required var_name
    if ENV[var_name].nil?
      raise "#{var_name} must be set"
    end
    ENV[var_name]
  end
  
  # Readline wrapper with injected history
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
    s.tr(' _', '-')
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
      normalised_branch_name = dashed n.match(/(^.*)(-[1-9][0-9]+$)?/)[1]
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
    dashed_story_name = (dashed story.name)[0..50].downcase
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
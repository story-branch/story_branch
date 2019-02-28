# frozen_string_literal: true

require 'blanket'
require_relative './string_utils'

module StoryBranch
  # Github Milestones representation
  class Milestone
    attr_accessor :id, :title, :description

    def initialize(milestone_data)
      @id = milestone_data.number
      @title = milestone_data.title
      @description = milestone_data.description
    end

    def to_s
      "MS: #{@title} - #{@description}"
    end
  end

  # Github Labels representation
  class Label
    attr_accessor :name, :color
    def initialize(label_data)
      @name = label_data.name
      @color = label_data.color
    end
  end

  # GitHub Issue representation
  class Story
    attr_accessor :title, :id

    def initialize(blanket_story, repo)
      @repo = repo
      @story = blanket_story
      @title = blanket_story.title
      @id = blanket_story.number
      @labels = blanket_story.labels.map { |label| Label.new(label) }
      @milestone = Milestone.new(blanket_story.milestone) if blanket_story.milestone
    end

    def update_state
      puts "What to do in github for this?"
    end

    def to_s
      "#{@id} - #{@title} [#{@milestone}]"
    end

    def dashed_title
      StoryBranch::StringUtils.normalised_branch_name @title
    end
  end

  # Github Repository representation
  class Project
    def initialize(blanket_project)
      @repo = blanket_project
    end

    def stories(options = {})
      stories = if options[:id]
                  [@repo.issues(options[:id]).get.payload]
                else
                  @repo.issues.get(params: options).payload
                end
      stories.map { |s| Story.new(s, @repo) }
    end
  end

  # Utility class for integration with PivotalTracker. It relies on Blanket
  # wrapper to communicate with pivotal tracker's api.
  class GithubUtils
    API_URL = 'https://api.github.com/'

    def initialize(repo_name, api_key)
      # NOTE: RepoName should follow owner/repo_name format
      @repo_name = repo_name
      @api_key = api_key
    end

    def valid?
      !@api_key.nil? && !@repo_name.nil?
    end

    def get_stories(options = {})
      project.stories
    end

    private

    def api
      raise 'API key must be specified' unless @api_key

      Blanket.wrap API_URL, headers: {
        'User-Agent' => 'Story Branch',
        Authorization: "token #{@api_key}"
      }
    end

    def project
      return @project if @project
      raise 'repo name must be set' unless @repo_name

      blanket_project = api.repos(@repo_name)
      @project = Project.new blanket_project
      @project
    end
  end
end

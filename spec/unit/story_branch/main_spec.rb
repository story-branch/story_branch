# frozen_string_literal: true

require 'spec_helper'
require 'story_branch/main'
require 'story_branch/config_manager'
require 'story_branch/git_utils'

# rubocop:disable Metrics/BlockLength
RSpec.describe StoryBranch::Main do
  let(:prompt) { TTY::TestPrompt.new }
  let(:sb) { StoryBranch::Main.new }
  let(:current_branch_name) { 'rspec-testing' }
  let(:branch_story_parts) { {} }
  let(:branch_exists) { false }
  let(:similar_branch) { false }
  let(:branch_name) { '' }
  let(:stories) { [] }
  let(:story_from_tracker) { nil }
  let(:answer_to_no) { false }
  let(:fake_project) { OpenStruct.new }
  let(:local_config) do
    conf = ::TTY::Config.new
    conf.set('project_id', value: '123456')
    conf
  end
  let(:global_config) do
    conf = ::TTY::Config.new
    conf.set('123456', 'api_key', value: 'myamazingkey')
    conf
  end
  let(:select_prompt_input) { "\r" }

  before do
    allow(fake_project).to receive(:stories)
    allow(StoryBranch::GitUtils).to receive_messages(
      current_branch_story_parts: branch_story_parts,
      branch_for_story_exists?: branch_exists,
      existing_branch?: similar_branch
    )
    allow(StoryBranch::GitWrapper).to receive_messages(
      create_branch: true,
      current_branch: current_branch_name,
      commit: true
    )
    allow(::TTY::Prompt).to receive(:new).and_return(prompt)

    allow(prompt).to receive(:select).and_call_original
    allow(prompt).to receive(:error)
    allow(prompt).to receive(:ok)
    allow(prompt).to receive(:say)
    allow(prompt).to receive(:yes?).and_return answer_to_no
    allow(prompt).to receive(:ask).and_return branch_name
    allow(StoryBranch::ConfigManager).to receive(:init_config) do |arg|
      if arg == '.'
        local_config
      elsif arg == Dir.home
        global_config
      end
    end
    allow(sb.tracker).to receive(:get_stories).and_return stories
    allow(sb.tracker).to receive(:get_story_by_id).and_return story_from_tracker
    prompt.input << select_prompt_input
    prompt.input.rewind
    sb
  end

  it 'loads the config files' do
    expect(StoryBranch::ConfigManager).to have_received(:init_config).exactly(2).times
  end

  describe 'tracker initialization' do
    describe 'when there is only one local project configured' do
      it 'initializes the PivotalTracker utils' do
        expect(sb.tracker).to_not be(nil)
        expect(sb.tracker.valid?).to eq true
      end
    end

    describe 'when there are multiple local projects configured' do
      let(:local_config) do
        conf = ::TTY::Config.new
        conf.set('project_id', value: %w[123456 54321])
        conf
      end
      let(:global_config) do
        conf = ::TTY::Config.new
        conf.set('123456', 'api_key', value: 'myamazingkey')
        conf
      end
      let(:select_prompt_input) do
        "\r\r"
      end

      xit 'prompts the user to choose the project to use' do
        expect(prompt).to have_received(:say)
          .with('Which project you want to fetch from?')
      end
    end
  end

  describe 'create_story_branch' do
    before do
      sb.create_story_branch
    end

    it 'gets the stories from the tracker' do
      expect(sb.tracker).to have_received(:get_stories).with('started')
    end

    describe 'when there are no features' do
      let(:stories) { [] }

      it 'prints message informing the user' do
        message = 'No stories started, exiting'
        expect(prompt).to have_received(:say).with(message)
      end
    end

    describe 'when there are features' do
      let(:stories) do
        fake_story = OpenStruct.new(name: 'test', id: '123456')
        [StoryBranch::Pivotal::Story.new(fake_story, fake_project)]
      end
      let(:story) { stories[0] }
      let(:branch_name) { story.dashed_title }
      let(:branch_name_with_id) { "#{branch_name}-#{story.id}" }

      it 'passes a structure to prompt select with story and text' do
        expected_select = {
          story.to_s => story
        }
        expect(prompt).to have_received(:select).with(
          'Choose the feature you want to work on:',
          expected_select,
          filter: true
        )
      end

      it 'asks for the branch name' do
        expect(prompt).to have_received(:ask).with(
          'Provide a new branch name',
          default: branch_name
        )
      end

      describe 'when the story id doesnt have a branch yet' do
        let(:branch_exists) { false }
        it 'creates the branch for the feature based on the feature name' do
          expect(StoryBranch::GitWrapper).to have_received(:create_branch)
            .with(branch_name_with_id)
        end
      end

      describe 'when the story id already has a branch' do
        let(:branch_exists) { true }

        it 'does not create a new branch' do
          expect(StoryBranch::GitWrapper).to_not have_received(:create_branch)
        end

        it 'shows an informative message' do
          message = "An existing branch has the same story id: #{story.id}"
          expect(prompt).to have_received(:error).with(message)
        end
      end

      describe 'when branch name is very similar to an exsiting one' do
        let(:similar_branch) { true }

        it 'does not create a new branch' do
          expect(StoryBranch::GitWrapper).to_not have_received(:create_branch)
        end

        it 'shows an informative message' do
          message = 'This name is very similar to an existing branch. '\
          'Avoid confusion and use a more unique name.'
          expect(prompt).to have_received(:error).with(message)
        end
      end
    end
  end

  describe 'story_start' do
    it 'fetches the stories from the tracker' do
      sb.story_start
      expect(sb.tracker).to have_received(:get_stories).with('unstarted')
    end

    describe 'when there are no unstarted features' do
      let(:stories) { [] }

      it 'prints message informing the user' do
        sb.story_start
        expect(prompt).to have_received(:say).with('No unstarted stories, exiting')
      end
    end

    describe 'when there are unstarted features' do
      let(:stories) do
        fake_story = OpenStruct.new(name: 'test', id: '123456')
        [StoryBranch::Pivotal::Story.new(fake_story, fake_project)]
      end
      let(:story) { stories[0] }
      let(:update_state_result) { OpenStruct.new(error: nil) }

      before do
        allow(story).to receive(:update_state).and_return update_state_result
        sb.story_start
      end

      it 'passes a structure to prompt select with story and text' do
        expected_select = {
          story.to_s => story
        }
        expect(prompt).to have_received(:select).with(
          'Choose the feature you want to start:',
          expected_select,
          filter: true
        )
      end

      describe 'when the update_state runs with success' do
        it 'triggers the upadate_state with the new state: started' do
          expect(story).to have_received(:update_state).with('started')
        end

        it 'prints the result to the user' do
          expect(prompt).to have_received(:ok).with("#{story.id} started")
        end
      end
    end
  end

  describe 'story_unstart' do
    it 'fetches the stories from the tracker' do
      sb.story_unstart
      expect(sb.tracker).to have_received(:get_stories).with('started')
    end

    describe 'when there are no started features' do
      let(:stories) { [] }

      it 'prints message informing the user' do
        sb.story_unstart
        expect(prompt).to have_received(:say).with('No started stories, exiting')
      end
    end

    describe 'when there are started features' do
      let(:stories) do
        fake_story = OpenStruct.new(name: 'test', id: '123456')
        [StoryBranch::Pivotal::Story.new(fake_story, fake_project)]
      end
      let(:story) { stories[0] }
      let(:update_state_result) { OpenStruct.new(error: nil) }

      before do
        allow(story).to receive(:update_state).and_return update_state_result
        sb.story_unstart
      end

      it 'passes a structure to prompt select with story and text' do
        expected_select = {
          story.to_s => story
        }
        expect(prompt).to have_received(:select).with(
          'Choose the feature you want to unstart:',
          expected_select,
          filter: true
        )
      end

      describe 'when the update_state runs with success' do
        it 'triggers the upadate_state with the new state: started' do
          expect(story).to have_received(:update_state).with('unstarted')
        end

        it 'prints the result to the user' do
          expect(prompt).to have_received(:ok).with("#{story.id} unstarted")
        end
      end
    end
  end

  describe 'story_finish' do
    describe 'when the branch name does not follow story branch format' do
      let(:branch_story_parts) { {} }
      let(:story_from_tracker) { 'something to check condition is met' }

      it 'prints the error message to the user' do
        sb.story_finish
        expect(prompt).to have_received(:error).with('No tracked feature associated with this branch')
      end
    end

    describe 'when the feature id does not match a feature in the tracker' do
      let(:branch_story_parts) { { title: 'amazing story', id: '111' } }
      let(:story_from_tracker) { nil }

      it 'tries to fetch the story from the tracker' do
        sb.story_finish
        expect(sb.tracker).to have_received(:get_story_by_id).with('111')
      end

      it 'prints the error message to the user' do
        sb.story_finish
        expect(prompt).to have_received(:error).with('No tracked feature associated with this branch')
      end
    end

    describe 'when there are untracked files' do
      let(:branch_story_parts) { { title: 'amazing story', id: '111' } }
      let(:story_from_tracker) do
        fake_story = OpenStruct.new(branch_story_parts)
        StoryBranch::Pivotal::Story.new(fake_story, fake_project)
      end

      before do
        allow(StoryBranch::GitUtils).to receive(:status?).and_return true
      end

      it 'prints the message informing the user' do
        sb.story_finish
        message = <<~MESSAGE
          There are unstaged changes
          Use git add to stage changes before running git finish
          Use git stash if you want to hide changes for this commit
        MESSAGE
        expect(prompt).to have_received(:say).once.with(message)
      end
    end

    describe 'when there are unstaged modified files' do
      let(:branch_story_parts) { { title: 'amazing story', id: '111' } }
      let(:story_from_tracker) do
        fake_story = OpenStruct.new(branch_story_parts)
        StoryBranch::Pivotal::Story.new(fake_story, fake_project)
      end

      before do
        allow(StoryBranch::GitUtils).to receive(:status?).and_return true
      end

      it 'prints the message informing the user' do
        sb.story_finish
        message = <<~MESSAGE
          There are unstaged changes
          Use git add to stage changes before running git finish
          Use git stash if you want to hide changes for this commit
        MESSAGE
        expect(prompt).to have_received(:say).once.with(message)
      end
    end

    describe 'when there are no changes to commit' do
      let(:branch_story_parts) { { title: 'amazing story', id: '111' } }
      let(:story_from_tracker) do
        fake_story = OpenStruct.new(branch_story_parts)
        StoryBranch::Pivotal::Story.new(fake_story, fake_project)
      end

      before do
        allow(StoryBranch::GitUtils).to receive(:status?).and_return false
      end

      it 'prints the message informing the user' do
        sb.story_finish
        message = <<~MESSAGE
          There are no staged changes.
          Nothing to do.
        MESSAGE
        expect(prompt).to have_received(:say).once.with(message)
      end
    end

    describe 'when there are staged changes to be commited' do
      let(:branch_story_parts) { { title: 'amazing story', id: '111' } }
      let(:story_from_tracker) do
        fake_story = OpenStruct.new(branch_story_parts)
        StoryBranch::Pivotal::Story.new(fake_story, fake_project)
      end
      let(:answer_to_no) { false }
      let(:commit_message) { '[Finishes #111] amazing story' }

      before do
        allow(StoryBranch::GitUtils).to receive(:status?) do |arg|
          !(arg == :untracked || arg == :modified)
        end
      end

      it 'prompts the user to commit with default message' do
        sb.story_finish
        expect(prompt).to have_received(:yes?).once
        expect(prompt).to have_received(:yes?)
          .with("Commit with standard message? #{commit_message}")
      end

      describe 'when the user says no' do
        let(:answer_to_no) { false }

        it 'aborts the commit' do
          sb.story_finish
          expect(prompt).to have_received(:say).with('Aborted')
        end
      end

      describe 'when the user says yes' do
        let(:answer_to_no) { true }

        it 'commits with the message' do
          sb.story_finish
          expect(StoryBranch::GitWrapper).to have_received(:commit)
            .with(commit_message)
        end
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength

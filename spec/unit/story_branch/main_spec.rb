# frozen_string_literal: true

require 'spec_helper'
require 'story_branch/main'
require 'story_branch/config_manager'
require 'story_branch/git_utils'

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

    allow(prompt).to receive(:select) do |arg|
      if arg == 'Which project you want to fetch from?'
        '123456'
      else
        stories[0]
      end
    end
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
    allow(sb.tracker).to receive(:stories).and_return stories
    allow(sb.tracker).to receive(:stories_with_state).and_return stories
    allow(sb.tracker).to receive(:get_story_by_id).and_return story_from_tracker
    sb
  end

  it 'loads the config files' do
    expect(StoryBranch::ConfigManager).to(
      have_received(:init_config).exactly(2).times
    )
  end

  describe 'tracker initialization' do
    describe 'when there is no tracker defined in config files' do
      it 'initializes pivotal tracker' do
        expect(sb.tracker).to_not be(nil)
        expect(sb.tracker.valid?).to eq true
        expect(sb.tracker.class).to eq StoryBranch::Pivotal::Tracker
      end
    end

    describe 'when there is a tracker defined in config files' do
      let(:local_config) do
        conf = ::TTY::Config.new
        conf.set('project_id', value: '123456')
        conf.set('tracker', value: 'github')
        conf
      end

      it 'initializes the matching tracker' do
        expect(sb.tracker).to_not be(nil)
        expect(sb.tracker.valid?).to eq true
        expect(sb.tracker.class).to eq StoryBranch::Github::Tracker
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

      it 'prompts the user to choose the project to use' do
        expect(prompt).to have_received(:select)
          .with('Which project you want to fetch from?', %w[123456 54321])
      end
    end
  end

  describe 'create_story_branch' do
    before do
      sb.create_story_branch
    end

    it 'gets the stories from the tracker' do
      expect(sb.tracker).to have_received(:stories)
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

        context 'settings set issue id to be in the beginning' do
          let(:local_config) do
            conf = ::TTY::Config.new
            conf.set('project_id', value: '123456')
            conf.set('issue_placement', value: 'beginning')
            conf
          end
          let(:branch_name_with_id) { "#{story.id}-#{branch_name}" }

          it 'creates the branch for the feature based on the feature name' do
            expect(StoryBranch::GitWrapper).to have_received(:create_branch)
              .with(branch_name_with_id)
          end
        end

        context 'when the branch name is not longer that 40 characters' do
          it 'creates the branch for the feature based on the feature name' do
            expect(StoryBranch::GitWrapper).to have_received(:create_branch)
              .with(branch_name_with_id)
          end
        end

        context 'when the branch name is longer than 40 characters' do
          let(:branch_name) { '0123456789_0123456789_0123456789_0123456789' }
          let(:branch_name_with_id) do
            "#{StoryBranch::StringUtils.truncate(branch_name)}-#{story.id}"
          end
          it 'creates the branch for the feature based on the truncated name' do
            expect(StoryBranch::GitWrapper).to have_received(:create_branch)
              .with(branch_name_with_id)
          end
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
      expect(sb.tracker).to have_received(:stories_with_state).with('unstarted')
    end

    describe 'when there are no unstarted features' do
      let(:stories) { [] }

      it 'prints message informing the user' do
        sb.story_start
        msg = 'No unstarted stories, exiting'
        expect(prompt).to have_received(:say).with msg
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
      expect(sb.tracker).to have_received(:stories_with_state).with('started')
    end

    describe 'when there are no started features' do
      let(:stories) { [] }

      it 'prints message informing the user' do
        sb.story_unstart
        msg = 'No started stories, exiting'
        expect(prompt).to have_received(:say).with msg
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
        msg = 'No tracked feature associated with this branch'
        expect(prompt).to have_received(:error).with msg
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
        msg = 'No tracked feature associated with this branch'
        expect(prompt).to have_received(:error).with msg
      end
    end

    describe 'when there are untracked files' do
      let(:branch_story_parts) { { title: 'amazing story', id: '111' } }
      let(:story_from_tracker) do
        instance_double(StoryBranch::Pivotal::Story,
                        title: 'amazing story', id: '111')
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
        instance_double(StoryBranch::Pivotal::Story,
                        title: 'amazing story', id: '111')
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
        instance_double(StoryBranch::Pivotal::Story,
                        title: 'amazing story', id: '111')
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
        instance_double(StoryBranch::Pivotal::Story,
                        title: 'amazing story', id: '111')
      end
      let(:answer_to_no) { false }
      let(:commit_message) { '[Finishes #111] amazing story' }

      before do
        allow(StoryBranch::GitUtils).to receive(:status?) do |arg|
          !%i[untracked modified].include? arg
        end
        sb.story_finish
      end

      context 'commit message is based on the settings' do
        context 'if the value is set to a word' do
          let(:local_config) do
            conf = ::TTY::Config.new
            conf.set('project_id', value: '123456')
            conf.set('finish_tag', value: 'Bananas')
            conf
          end
          let(:commit_message) { '[Bananas #111] amazing story' }

          it 'prompts the user to commit with default message' do
            expect(prompt).to have_received(:yes?).once
            expect(prompt).to have_received(:yes?)
              .with("Commit with standard message? #{commit_message}")
          end
        end

        context 'if the value is set to an empty string' do
          let(:local_config) do
            conf = ::TTY::Config.new
            conf.set('project_id', value: '123456')
            conf.set('finish_tag', value: '')
            conf
          end
          let(:commit_message) { '[#111] amazing story' }

          it 'prompts the user to commit with default message' do
            expect(prompt).to have_received(:yes?).once
            expect(prompt).to have_received(:yes?)
              .with("Commit with standard message? #{commit_message}")
          end
        end
      end

      it 'prompts the user to commit with default message' do
        expect(prompt).to have_received(:yes?).once
        expect(prompt).to have_received(:yes?)
          .with("Commit with standard message? #{commit_message}")
      end

      describe 'when the user says no' do
        let(:answer_to_no) { false }

        it 'aborts the commit' do
          expect(prompt).to have_received(:say).with('Aborted')
        end
      end

      describe 'when the user says yes' do
        let(:answer_to_no) { true }

        it 'commits with the message' do
          expect(StoryBranch::GitWrapper).to have_received(:commit)
            .with(commit_message)
        end
      end
    end
  end
end

# frozen_string_literal: true

require 'spec_helper'
require 'story_branch/github/project'

# rubocop:disable Metrics/BlockLength
RSpec.describe StoryBranch::Github::Project do
  describe 'stories' do
    let(:blanket_project) { double('project') }
    let(:project) { described_class.new(blanket_project) }
    let(:issues_double) { double('issues', get: get_double) }

    before do
      allow(StoryBranch::Github::Issue).to receive(:new)
      allow(blanket_project).to receive(:issues).and_return(issues_double)
    end

    describe 'when options passed include id attribute' do
      let(:matching_issue) { OpenStruct.new(title: 'Issue') }
      let(:get_double) { double('get', payload: matching_issue) }

      before do
        project.stories(id: 10)
      end

      it 'returns an array of issues with one story only' do
        expect(blanket_project).to have_received(:issues).with(10)
      end

      it 'initializes Issues with the payload' do
        expect(StoryBranch::Github::Issue).to have_received(:new)
          .with(matching_issue, blanket_project)
      end
    end

    describe 'when options do not have id attribute' do
      let(:all_issues) do
        [OpenStruct.new(title: 'Issue1'),
         OpenStruct.new(title: 'Issue2'),
         OpenStruct.new(title: 'PR1', pull_request: {})]
      end
      let(:get_double) { double('get', payload: all_issues) }

      before do
        project.stories(state: 'open')
      end

      it 'calls issues' do
        expect(blanket_project).to have_received(:issues)
      end

      it 'calls get in the issues with the params' do
        expect(issues_double).to have_received(:get)
          .with(params: { state: 'open' })
      end

      it 'initializes Issues with the payload' do
        expect(StoryBranch::Github::Issue).to have_received(:new)
          .with(all_issues[0], blanket_project).once
        expect(StoryBranch::Github::Issue).to have_received(:new)
          .with(all_issues[1], blanket_project).once
        expect(StoryBranch::Github::Issue).to_not have_received(:new)
          .with(all_issues[2], blanket_project)
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength

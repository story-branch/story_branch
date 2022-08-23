# frozen_string_literal: true

require 'spec_helper'
require 'story_branch/graphql'
require 'story_branch/linear_app/team'

RSpec.describe StoryBranch::LinearApp::Team do
  let(:client) { StoryBranch::Graphql::Client.new(api_url: 'https://api.linear.app/', api_key: '1231123') }
  let(:team_key) { 'BAN' }
  let(:stories) do
    OpenStruct.new(data: {
                     'viewer' => {
                       'assignedIssues' => {
                         'nodes' => [
                           'title' => 'Hello',
                           'number' => '123123',
                           'url' => 'https://googl.e'
                         ]
                       }
                     }
                   })
  end

  let(:expected_graphql_query) do
    # rubocop:disable Layout/LineLength
    "\n query Issue {\n viewer {\n assignedIssues (filter: { team: { key: { eq: \"BAN\"} } }) {\n nodes {\n id\n title\n description\n number\n url\n }\n }\n }\n }\n "
    # rubocop:enable Layout/LineLength
  end

  before do
    allow(client).to receive(:get).and_return(stories)
  end

  describe 'stories' do
    it 'fetches the stories from graphql client' do
      team = described_class.new(team_key, client)
      stories = team.stories

      expect(client).to have_received(:get).with(graphql_query: expected_graphql_query)

      expect(stories.length).to eq 1
      expect(stories[0].is_a?(StoryBranch::LinearApp::Issue)).to be true
      expect(stories[0].to_s).to eq 'BAN-123123 - Hello'
    end
  end
end

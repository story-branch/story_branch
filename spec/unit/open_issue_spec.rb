# frozen_string_literal: true

require 'story_branch/url_opener'
require 'story_branch/commands/open_issue'

RSpec.describe StoryBranch::Commands::OpenIssue do
  let(:output) { StringIO.new }
  let(:options) { {} }

  before do
    allow(StoryBranch::UrlOpener).to receive(:open_url).and_return true
    command = StoryBranch::Commands::OpenIssue.new(options)
    command.execute(output: output)
  end

  it 'executes `open_issue` command successfully' do
    expect(output.string).to eq('true')
  end

  it 'opens url' do
    expect(StoryBranch::UrlOpener).to have_received(:open_url)
  end
end

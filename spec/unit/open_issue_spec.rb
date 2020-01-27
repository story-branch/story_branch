# frozen_string_literal: true

require 'story_branch/url_opener'
require 'story_branch/commands/open_issue'

RSpec.describe StoryBranch::Commands::OpenIssue do
  before do
    allow(StoryBranch::UrlOpener).to receive(:open_url).and_return true
  end

  it 'executes `open_issue` command successfully' do
    output = StringIO.new
    options = {}
    command = StoryBranch::Commands::OpenIssue.new(options)

    command.execute(output: output)

    expect(output.string).to eq('true')
  end
end

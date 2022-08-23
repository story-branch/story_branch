# frozen_string_literal: true

require 'story_branch/main'
require 'story_branch/commands/open_issue'

RSpec.describe StoryBranch::Commands::OpenIssue do
  let(:output) { StringIO.new }
  let(:options) { {} }
  let(:sb_double) { double(StoryBranch::Main, open_current_url: true) }

  before do
    allow(StoryBranch::Main).to receive(:new).and_return sb_double
    command = described_class.new(options)
    command.execute(output: output)
  end

  it 'executes `open_issue` command successfully' do
    expect(output.string).to eq('true')
  end

  it 'opens url' do
    expect(sb_double).to have_received(:open_current_url)
  end
end

# frozen_string_literal: true

require 'story_branch/commands/start'

RSpec.describe StoryBranch::Commands::Start do
  let(:sb) { instance_double(::StoryBranch::Main, story_start: true) }

  before do
    allow(::StoryBranch::Main).to receive(:new).and_return(sb)
  end

  it 'invokes story branch main create method' do
    command = described_class.new({})
    command.execute
    expect(sb).to have_received(:story_start)
  end
end

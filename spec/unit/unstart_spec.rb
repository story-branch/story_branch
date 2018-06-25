# frozen_string_literal: true

require 'story_branch/commands/unstart'

RSpec.describe StoryBranch::Commands::Unstart do
  let(:sb) { instance_double(::StoryBranch::Main, story_unstart: true) }

  before do
    allow(::StoryBranch::Main).to receive(:new).and_return(sb)
  end

  it 'invokes story branch main create method' do
    command = StoryBranch::Commands::Unstart.new({})
    command.execute
    expect(sb).to have_received(:story_unstart)
  end
end

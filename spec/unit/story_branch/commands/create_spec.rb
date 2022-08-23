# frozen_string_literal: true

require 'story_branch/commands/create'
require 'story_branch/main'

RSpec.describe StoryBranch::Commands::Create do
  let(:sb) { instance_double(::StoryBranch::Main, create_story_branch: true) }

  before do
    allow(::StoryBranch::Main).to receive(:new).and_return(sb)
  end

  it 'invokes story branch main create method' do
    command = described_class.new({})
    command.execute
    expect(sb).to have_received(:create_story_branch)
  end
end

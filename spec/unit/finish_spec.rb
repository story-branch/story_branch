# frozen_string_literal: true

require 'story_branch/commands/finish'
require 'story_branch/main'

RSpec.describe StoryBranch::Commands::Finish do
  let(:sb) { instance_double(::StoryBranch::Main, story_finish: true) }

  before do
    allow(::StoryBranch::Main).to receive(:new).and_return(sb)
  end

  it 'invokes story branch main finish method' do
    command = StoryBranch::Commands::Finish.new({})
    command.execute
    expect(sb).to have_received(:story_finish)
  end
end

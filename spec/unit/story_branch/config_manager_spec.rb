# frozen_string_literal: true

require 'spec_helper'
require 'story_branch/config_manager'

RSpec.describe StoryBranch::ConfigManager do
  let(:prompt) { TTY::TestPrompt.new }

  before do
    allow(::TTY::Prompt).to receive(:new).and_return(prompt)
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

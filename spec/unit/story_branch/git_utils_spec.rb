# frozen_string_literal: true

require 'spec_helper'
require 'story_branch/git_utils'
require 'ostruct'

RSpec.describe StoryBranch::GitUtils do
  let(:command_output) { [] }
  describe 'g' do
    before do
      g_lib = double(Git::Lib, send: OpenStruct.new(lines: command_output))
      double(::Git, open: g_lib)
    end

    it 'uses Git gem to open the local git directory' do
      StoryBranch::GitUtils.g
      expect(Git).to have_received(:open).with('.')
    end
  end

  describe 'branch_for_story_exists?' do
    describe 'existing branches include the passed id' do
      it 'returns true' do

      end
    end

    describe 'existing branches does not include the passed id' do
      it 'returns false' do
      end
    end
  end
end

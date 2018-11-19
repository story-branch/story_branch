# frozen_string_literal: true

require 'spec_helper'
require 'story_branch/git_utils'
require 'ostruct'

# TODO: Write the specs for git utils
# RSpec.describe StoryBranch::GitUtils do
#   let(:command_output) { [] }
#   let(:g_lib) { double(Git::Lib, send: OpenStruct.new(lines: command_output)) }

#   before do
#     g_base = double(Git::Base, lib: g_lib)
#     allow(::Git).to receive(:open).and_return g_base
#   end

#   describe 'g' do
#     it 'uses Git gem to open the local git directory' do
#       StoryBranch::GitUtils.g
#       expect(Git).to have_received(:open).with('.')
#     end
#   end

#   describe 'branch_for_story_exists?' do
#     describe 'existing branches include the passed id' do
#       let(:command_output) { %w[amazing-name-1 amazing-feature-2] }

#       it 'fetches all branches with command execution' do
#         StoryBranch::GitUtils.branch_for_story_exists?(1)
#         expect(g_lib).to have_received(:send).with([:command, 'branch', '-a'])
#       end

#       it 'returns true' do
#         expect(StoryBranch::GitUtils.branch_for_story_exists?(1)).to eq true
#       end
#     end

#     describe 'existing branches does not include the passed id' do
#       it 'returns false' do
#       end
#     end
#   end
# end

# frozen_string_literal: true

require 'spec_helper'
require 'story_branch/git_wrapper'

RSpec.describe StoryBranch::GitWrapper do
  let(:output) { '' }

  before do
    allow_any_instance_of(described_class).to receive(:`).and_return(output)
  end

  describe 'GitWrapper.command' do
    describe 'when output has multiple lines' do
      let(:output) { "  test_dir\nbananas\nanother-thing\n" }

      it 'returns system call output chomped and striped' do
        res = described_class.command('branch', '-a')
        expect(res).to eq "test_dir\nbananas\nanother-thing"
      end
    end

    describe 'when the output has one line' do
      let(:output) { "   test_dir\n" }

      it 'returns system call output chomped and striped' do
        res = described_class.command('branch', '-a')
        expect(res).to eq 'test_dir'
      end
    end
  end

  describe 'GitWrapper.command_lines' do
    describe 'when output has multiple lines' do
      let(:output) { "  test_dir\n   bananas\n   another-thing\n" }

      it 'returns system call output in an array chomped and striped' do
        res = described_class.command_lines('branch', '-a')
        expect(res).to eq ['test_dir', 'bananas', 'another-thing']
      end
    end

    describe 'when the output has one line' do
      let(:output) { "   test_dir\n" }

      it 'returns system call output chomped and striped' do
        res = described_class.command_lines('branch', '-a')
        expect(res).to eq ['test_dir']
      end
    end
  end
end

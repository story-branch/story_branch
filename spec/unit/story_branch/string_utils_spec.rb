# frozen_string_literal: true

require 'spec_helper'
require 'story_branch/string_utils'

RSpec.describe StoryBranch::StringUtils do
  let(:simple_string) { "$%^*()<H_e,l l::o.W;h+o&?'A#r`e'>@" }

  describe 'dashed' do
    it 'converts non alphabet to dash' do
      dashed = described_class.dashed(simple_string)
      expect(dashed).to eq 'H-e-l-l-o-W-h-o-A-r-e'
    end
  end

  describe 'sanitize' do
    it 'strips out the non-ascii character' do
      some_ascii = "abc\n"
      some_unicode = 'áëëçüñżλφθΩ𠜎😸'
      more_ascii = "123ABC\n"
      invalid_byte = "\255"
      test_string = [some_ascii, some_unicode, more_ascii, invalid_byte].join

      sanitized = described_class.sanitize(test_string)
      result_string = 'abc---e-----------123ABC'
      expect(sanitized).to eq result_string
    end
  end

  describe 'normalised_branch_name' do
    it 'downcases the dashed string' do
      res = described_class.normalised_branch_name(simple_string)
      expect(res).to eq 'h-e-l-l-o-w-h-o-a-r-e'
    end
  end

  describe 'undashed' do
    it 'converts dashed string into human readable' do
      str = 'abc---e-----------123ABC'
      res = described_class.undashed(str)
      expect(res).to eq 'Abc e 123abc'
      str = 'h-e-l-l-o-w-h-o-are-'
      res = described_class.undashed(str)
      expect(res).to eq 'H e l l o w h o are'
    end
  end

  describe 'truncate' do
    it 'returns the original string if the length is less than max length' do
      str = 'amazing bananas'
      res = described_class.truncate(str)
      expect(res).to eq str
    end

    it 'returns the original string if the length is less than max length' do
      str = 'amazing bananas'
      res = described_class.truncate(str, str.length)
      expect(res).to eq str
    end

    it 'returns the truncated string if the length is greater than max' do
      str = 'amazing bananas'
      res = described_class.truncate(str, 7)
      expect(res).to eq 'amazing'
    end
  end
end

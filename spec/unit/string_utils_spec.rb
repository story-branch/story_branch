# frozen_string_literal: true
require 'spec_helper'
require 'story_branch/string_utils'

RSpec.describe StoryBranch::StringUtils do
  describe 'dashed' do
    it 'converts non alphabet to dash' do
      dashed = StoryBranch::StringUtils.dashed("H_e,l l::o.W;h+o&?'Are'")
      expect(dashed).to eq 'H-e-l-l--o-W-h-o---Are-'
    end
  end
end

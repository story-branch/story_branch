# frozen_string_literal: true

RSpec.describe '`story_branch unstart` command', type: :cli do
  it 'executes `story_branch help unstart` command successfully' do
    output = `exe/story_branch help unstart`
    expected_output = <<~OUT
      Usage:
        story_branch unstart

      Options:
        -h, [--help], [--no-help]  # Display usage information

      Mark a started story as un-started [Only for Pivotal Tracker]
    OUT

    expect(output).to eq(expected_output)
  end
end

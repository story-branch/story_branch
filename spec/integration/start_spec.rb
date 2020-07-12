# frozen_string_literal: true

RSpec.describe '`story_branch start` command', type: :cli do
  it 'executes `story_branch help start` command successfully' do
    output = `exe/story_branch help start`
    expected_output = <<~OUT
      Usage:
        story_branch start

      Options:
        -h, [--help], [--no-help]  # Display usage information

      Mark an estimated story as started [Only for Pivotal Tracker]
    OUT

    expect(output).to eq(expected_output)
  end
end

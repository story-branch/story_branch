# frozen_string_literal: true

RSpec.describe '`story_branch create` command', type: :cli do
  it 'executes `story_branch help create` command successfully' do
    output = `exe/story_branch help create`
    expected_output = <<~OUT
      Usage:
        story_branch create

      Options:
        -h, [--help], [--no-help]  # Display usage information

      Create branch from a ticket in the tracker
    OUT

    expect(output).to eq(expected_output)
  end
end

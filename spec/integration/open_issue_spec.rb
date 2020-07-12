# frozen_string_literal: true

RSpec.describe '`story_branch open_issue` command', type: :cli do
  it 'executes `story_branch help open_issue` command successfully' do
    output = `story_branch help open_issue`
    expected_output = <<~OUT
      Usage:
        story_branch open_issue

      Options:
        -h, [--help], [--no-help]  # Display usage information

      Open ticket in the configured tracker
    OUT

    expect(output).to eq(expected_output)
  end
end

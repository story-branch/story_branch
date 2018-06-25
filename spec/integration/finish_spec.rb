# frozen_string_literal: true

RSpec.describe '`story_branch finish` command', type: :cli do
  it 'executes `story_branch help finish` command successfully' do
    output = `exe/story_branch help finish`
    expected_output = <<~OUT
      Usage:
        story_branch finish

      Options:
        -h, [--help], [--no-help]  # Display usage information

      Creates a git commit message for the staged changes with a [Finishes] tag
    OUT

    expect(output).to eq(expected_output)
  end
end

# frozen_string_literal: true

RSpec.describe '`story_branch configure` command', type: :cli do
  it 'executes `story_branch help configure` command successfully' do
    output = `exe/story_branch help configure`
    expected_output = <<~OUT
      Usage:
        story_branch configure

      Options:
        -h, [--help], [--no-help]  # Display usage information

      Add a new story branch configuration
    OUT

    expect(output).to eq(expected_output)
  end
end

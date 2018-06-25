# frozen_string_literal: true

RSpec.describe '`story_branch migrate` command', type: :cli do
  it 'executes `story_branch help migrate` command successfully' do
    output = `exe/story_branch help migrate`
    expected_output = <<~OUT
      Usage:
        story_branch migrate

      Options:
        -h, [--help], [--no-help]  # Display usage information

      Migrate old story branch configuration to the new format
    OUT

    expect(output).to eq(expected_output)
  end
end

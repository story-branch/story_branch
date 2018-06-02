RSpec.describe '`story_branch create` command', type: :cli do
  it 'executes `story_branch help create` command successfully' do
    output = `story_branch help create`
    expected_output = <<-OUT
Usage:
  story_branch create

Options:
  -h, [--help], [--no-help]  # Display usage information

Create branch from estimated stories in pivotal tracker
    OUT

    expect(output).to eq(expected_output)
  end
end

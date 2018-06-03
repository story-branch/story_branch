RSpec.describe "`story_branch add` command", type: :cli do
  it "executes `story_branch help add` command successfully" do
    output = `story_branch help add`
    expected_output = <<-OUT
Usage:
  story_branch add

Options:
  -h, [--help], [--no-help]  # Display usage information

Add a new story branch configuration
    OUT

    expect(output).to eq(expected_output)
  end
end

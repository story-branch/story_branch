require 'story_branch/commands/open_issue'

RSpec.describe StoryBranch::Commands::OpenIssue do
  it "executes `open_issue` command successfully" do
    output = StringIO.new
    options = {}
    command = StoryBranch::Commands::OpenIssue.new(options)

    command.execute(output: output)

    expect(output.string).to eq("OK\n")
  end
end

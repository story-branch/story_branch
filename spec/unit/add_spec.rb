require 'story_branch/commands/add'

RSpec.describe StoryBranch::Commands::Add do
  it "executes `add` command successfully" do
    output = StringIO.new
    options = {}
    command = StoryBranch::Commands::Add.new(options)

    command.execute(output: output)

    expect(output.string).to eq("OK\n")
  end
end

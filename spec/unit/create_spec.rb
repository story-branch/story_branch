require 'story_branch/commands/create'

RSpec.describe StoryBranch::Commands::Create do
  it "executes `create` command successfully" do
    output = StringIO.new
    options = {}
    command = StoryBranch::Commands::Create.new(options)

    command.execute(output: output)

    expect(output.string).to eq("OK\n")
  end
end

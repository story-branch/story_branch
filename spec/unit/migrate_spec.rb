require 'story_branch/commands/migrate'

RSpec.describe StoryBranch::Commands::Migrate do
  it "executes `migrate` command successfully" do
    output = StringIO.new
    options = {}
    command = StoryBranch::Commands::Migrate.new(options)

    command.execute(output: output)

    expect(output.string).to eq("OK\n")
  end
end

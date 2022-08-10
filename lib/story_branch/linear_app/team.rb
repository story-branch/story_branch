# frozen_string_literal: true

require_relative 'issue'

module StoryBranch
  module LinearApp
    # LinearApp groups tickets in teams, so this is the team representation in
    # story branch. It's equivalent to a project
    class Team
      def initialize(team_id, client)
        @team_id = team_id
        @client = client
      end

      def stories(_options = {})
        response = @client.get(graphql_query: graphql_query)
        stories_json = response.data['viewer']['assignedIssues']['nodes']
        stories_json.map { |story| Issue.new(story, @team_id) }
      rescue StoryBranch::Graphql::Error => e
        raise "Error while querying for tickets:\n#{e.message}"
      end

      private

      def graphql_query # rubocop:disable Metrics/MethodLength
        %(
          query Issue {
            viewer {
              assignedIssues (filter: { team: { name: { eq: "#{@team_id}"} } }) {
                nodes {
                  id
                  title
                  description
                  number
                  url
                }
              }
            }
          }
        )
      end
    end
  end
end

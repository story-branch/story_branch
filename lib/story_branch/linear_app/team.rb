# frozen_string_literal: true

require_relative 'issue'

module StoryBranch
  module LinearApp
    class Team
      def initialize(team_id, client)
        @team_id = team_id
        @client = client
      end

      def stories(_options = {})
        response = @client.get(graphql_query: graphql_query)
        stories_json = response.data['viewer']['assignedIssues']['nodes']
        stories_json.map { |story| Issue.new(story, @team_id) }
      rescue StoryBranch::GraphqlClientError => e
        raise "Error while querying for tickets:\n#{e.message}"
      end

      private

      def graphql_query
        %Q(
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

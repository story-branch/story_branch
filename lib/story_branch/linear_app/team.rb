# frozen_string_literal: true

require_relative './issue'

module StoryBranch
  module LinearApp
    class Team
      def initialize(team_id, client)
        @team_id = team_id
        @client = client
      end

      def stories(_options = {})
        # TODO: handle graphql errors
        response = @client.get(graphql_query)
        stories_json = response.parsed_response['data']['team']['issues']['nodes']
        stories_json.map { |story| Issue.new(story, @team_id) }
      end

      private

      def graphql_query
        %Q(
          query Team {
            team(id: "#{@team_id}") {
              id
              name
              issues {
                nodes {
                  id
                  title
                  description
                  number
                  url
                  assignee {
                    id
                    name
                  }
                  createdAt
                  archivedAt
                }
              }
            }
          }
        )
      end
    end
  end
end

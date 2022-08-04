# frozen_string_literal: true

require 'httparty'

module StoryBranch
  module LinearApp
    class Client
      API_URL = 'https://api.linear.app/'

      include HTTParty
      base_uri API_URL

      def initialize(api_key)
        @auth = api_key
      end

      def get(graphql_query)
        body_json = query_params_json(graphql_query)
        self.class.post('/graphql', headers: headers, body: body_json)
      end

      private

      def headers
        {
          Authorization: @auth,
          'Content-Type': 'application/json'
        }
      end

      def query_params_json(graphql_query)
        { query: graphql_query }.to_json
      end
    end
  end
end

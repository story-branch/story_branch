# frozen_string_literal: true

require 'httparty'

module StoryBranch
  module LinearApp
    class ClientError < StandardError; end

    class Client
      API_URL = 'https://api.linear.app/'

      include HTTParty
      base_uri API_URL

      def initialize(api_key)
        @auth = api_key
      end

      def get(graphql_query)
        body_json = query_params_json(graphql_query)
        gql_response = self.class.post('/graphql', headers: headers, body: body_json)
        response = GraphQlResponse.new(response: gql_response)
        raise ClientError, response.full_error_messages unless response.success?

        response
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

    class GraphQlResponse
      def initialize(response:)
        @response = response
      end

      def data
        @data ||= @response.parsed_response['data']
      end

      def success?
        errors.nil?
      end

      def errors
        @errors ||= @response.parsed_response['errors']
      end

      def full_error_messages
        errors.join("\n")
      end
    end
  end
end

# frozen_string_literal: true

require 'httparty'

require_relative 'graphql_response'

module StoryBranch
  class GraphqlClientError < StandardError; end

  class GraphqlClient
    def initialize(api_url:, api_key:)
      @api_url = api_url
      @auth = api_key
    end

    def get(graphql_query:, endpoint: 'graphql')
      body_json = query_params_json(graphql_query)

      gql_response = HTTParty.post(graphql_endpoint(endpoint), headers: headers, body: body_json)
      response = GraphqlResponse.new(response: gql_response)
      raise GraphqlClientError, response.full_error_messages unless response.success?

      response
    end

    private

    def graphql_endpoint(endpoint)
      "#{@api_url}#{endpoint}"
    end

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

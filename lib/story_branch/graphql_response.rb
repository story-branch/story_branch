# frozen_string_literal: true

class GraphqlResponse
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

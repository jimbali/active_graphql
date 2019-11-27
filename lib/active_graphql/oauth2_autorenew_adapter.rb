# frozen_string_literal: true

require_relative 'oauth2_server_error'

# The underlying GraphQL library has lots of noisy warnings if included twice
$VERBOSE = nil
require 'graphlient/adapters/http/adapter'
$VERBOSE = @with_warnings

module ActiveGraphql
  class Oauth2AutorenewAdapter < Graphlient::Adapters::HTTP::Adapter
    class << self
      def configure(access_token: nil)
        @access_token = access_token
      end

      attr_reader :access_token
    end

    def execute(document:, variables:, **_other_options)
      body = {
        query: document.to_query_string,
        variables: variables
      }.to_json

      response = Oauth2AutorenewAdapter.access_token.post_and_retry(
        body, headers: headers
      )

      JSON.parse(response.body)
    rescue OAuth2::Error => e
      raise Oauth2ServerError, e
    end

    private

    def headers
      { 'Content-Type' => 'application/json' }
    end
  end
end

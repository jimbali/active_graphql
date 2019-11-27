# frozen_string_literal: true

require 'json'
require 'active_graphql/oauth2_autorenew_adapter'

# The underlying GraphQL library has lots of noisy warnings when booting
$VERBOSE = nil
require 'graphlient'
$VERBOSE = @with_warnings

module ActiveGraphql
  class Client
    def initialize(access_token, graphlient: nil)
      @access_token = access_token
      @graphlient = graphlient || Graphlient::Client.new(
        nil, http: Oauth2AutorenewAdapter
      )
      Oauth2AutorenewAdapter.configure(access_token: access_token)
    end

    def result(query, *dig)
      result = run_query(query)
      result.dig(*dig)
    end

    def query(query, variables = nil)
      response = graphlient.execute(query, variables)
      raise ActiveGraphql::Error, response.errors if response.errors.any?

      response.original_hash
    rescue JSON::ParserError, Graphlient::Errors::GraphQLError => e
      raise ActiveGraphql::Error, e.message
    end

    private

    attr_reader :access_token, :graphlient
  end
end

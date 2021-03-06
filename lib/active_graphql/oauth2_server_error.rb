# frozen_string_literal: true

# The underlying GraphQL library has lots of noisy warnings when booting
$VERBOSE = nil
require 'graphlient'
$VERBOSE = @with_warnings

module ActiveGraphql
  class Oauth2ServerError < Graphlient::Errors::ServerError
    attr_reader :response, :status_code
    def initialize(inner_exception)
      super(inner_exception.message, inner_exception)
      @inner_exception = inner_exception
      @response = inner_exception.response.body
      @status_code = inner_exception.response.status
    end
  end
end

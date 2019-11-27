# frozen_string_literal: true

require 'active_graphql/base_model'
require 'active_graphql/client'
require 'active_graphql/version'

module ActiveGraphql
  class Error < StandardError; end

  class << self
    def configure(access_token, graphlient: nil)
      @access_token = access_token
      @graphlient = graphlient
    end

    def client
      @client ||= Client.new(access_token, graphlient: graphlient)
    end

    private

    attr_reader :access_token, :graphlient
  end
end

# frozen_string_literal: true

require 'active_support/concern'
require 'active_support/inflector'

module ActiveGraphql
  module BaseModel
    module Queryable
      extend ActiveSupport::Concern

      class_methods do
        def query(query = nil)
          @query = query if query
          @query ||= generate_query
        end

        def query_result_path(result_path = nil)
          @query_result_path = result_path if result_path
          @query_result_path ||= generate_query_result_path
        end

        def generate_query_result_path
          ['data', object_type.downcase.pluralize]
        end

        def generate_query
          <<~GRAPHQL
            query {
              #{object_type.downcase.pluralize} {
                #{attribute_names.join(' ')}
              }
            }
          GRAPHQL
        end

        def all
          result = client.query(query)
          result.dig(*query_result_path)
        end
      end
    end
  end
end

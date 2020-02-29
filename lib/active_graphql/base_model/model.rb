# frozen_string_literal: true

require 'active_model'
require 'active_support/inflector'
require 'active_graphql/base_model/attributes'
require 'active_graphql/base_model/has_attributes'
require 'active_graphql/base_model/mutable'
require 'active_graphql/client'
require 'active_graphql/error'

module ActiveGraphql
  module BaseModel
    class Model
      include ActiveModel::Model
      include ActiveModel::AttributeMethods
      include BaseModel::HasAttributes
      include BaseModel::Mutable

      class << self
        def client
          ActiveGraphql.client
        end

        def query(query = nil)
          @query = query if query
          @query ||= generate_query
        end

        def object_type(object_type = nil)
          @object_type = object_type if object_type
          @object_type ||= name
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

      delegate :client, to: :class
    end
  end
end

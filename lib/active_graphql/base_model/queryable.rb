# frozen_string_literal: true

require 'active_support/concern'
require 'active_support/inflector'
require 'graphql/define/type_definer'

module ActiveGraphql
  module BaseModel
    module Queryable
      extend ActiveSupport::Concern

      class_methods do
        def query(query = nil)
          @query = query if query
          @query ||= generate_query
        end

        def filter(field, type)
          @query = nil
          filters[field] = type
        end

        def filters
          @filters ||= {}
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
            query#{query_variables} {
              #{object_type.downcase.pluralize}#{query_filters} {
                #{attribute_names.join(' ')}
              }
            }
          GRAPHQL
        end

        def query_variables
          return '' if filters.empty?

          "(#{filters.map { |name, type| "$#{name}: #{type}" }.join(', ')})"
        end

        def query_filters
          return '' if filters.empty?

          "(#{filters.map { |name, _| "#{name}: $#{name}" }.join(', ')})"
        end

        def types
          GraphQL::Define::TypeDefiner.instance
        end

        def all
          result = client.query(query)
          result.dig(*query_result_path)
        end

        def find_by!(**args)
          result = client.query(query, **args)
          puts result.inspect
          result.dig(*query_result_path)
        end
      end
    end
  end
end

# frozen_string_literal: true

require 'active_model'
require 'active_support/inflector'
require 'active_graphql/base_model/attributes'
require 'active_graphql/base_model/has_attributes'
require 'active_graphql/client'
require 'active_graphql/error'

module ActiveGraphql
  module BaseModel
    class Model
      include ActiveModel::Model
      include ActiveModel::AttributeMethods
      include BaseModel::HasAttributes

      class << self
        attr_reader :create_mutation, :create_variables, :update_mutation,
                    :update_variables

        def client
          ActiveGraphql.client
        end

        def set_create(mutation:, variables: {})
          @create_mutation = mutation
          @create_variables = variables
        end

        def set_update(mutation:, variables: {})
          @update_mutation = mutation
          @update_variables = variables
        end

        def query(query = nil)
          @query = query if query
          @query ||= generate_query
        end

        def object_type(object_type = nil)
          @object_type = object_type if object_type
          @object_type ||= name
        end

        def create_result_path(result_path = nil)
          @create_result_path = result_path if result_path
          @create_result_path ||= generate_mutation_result_path('create')
        end

        def generate_mutation_result_path(operation)
          ['data', "#{operation}#{object_type}", object_type.downcase]
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

      def create_variables
        instance_exec(&self.class.create_variables)
      end

      def update_variables
        instance_exec(&self.class.update_variables)
      end

      def save
        save!
      rescue ActiveGraphql::Error
        false
      end

      def save!
        result = client.query(*mutation_params)

        after_save(result.dig(*self.class.create_result_path))
      end

      def object_type
        self.class.object_type
      end

      def mutation_params
        return [self.class.create_mutation, create_variables] if id.nil?

        [self.class.update_mutation, update_variables]
      end

      def after_save(object)
        return if object.nil?

        public_send(:id=, object['id']) if id.nil?
      end

      delegate :client, to: :class
    end
  end
end

# frozen_string_literal: true

require 'active_support/concern'

module ActiveGraphql
  module BaseModel
    module Queryable
      extend ActiveSupport::Concern

      class_methods do
        attr_reader :create_mutation, :create_variables, :update_mutation,
                    :update_variables

        def set_create(mutation:, variables: {})
          @create_mutation = mutation
          @create_variables = variables
        end

        def set_update(mutation:, variables: {})
          @update_mutation = mutation
          @update_variables = variables
        end

        def create_result_path(result_path = nil)
          @create_result_path = result_path if result_path
          @create_result_path ||= generate_mutation_result_path('create')
        end

        def generate_mutation_result_path(operation)
          ['data', "#{operation}#{object_type}", object_type.downcase]
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
    end
  end
end

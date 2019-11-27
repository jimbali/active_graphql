# frozen_string_literal: true

require 'active_model'
require 'active_graphql/base_model/attributes'
require 'active_graphql/client'

module ActiveGraphql
  module BaseModel
    class Model
      include ActiveModel::Model
      include ActiveModel::AttributeMethods

      class << self
        attr_reader :create_mutation, :create_variables, :update_mutation,
                    :update_variables

        def client
          ActiveGraphql.client
        end

        def attribute(name, opts = {})
          add_attribute(name, opts)
          attr_accessor name
        end

        def add_attribute(name, opts)
          define_attribute_method(name)
          model_attributes.add(name, opts)
        end

        def model_attributes
          @model_attributes ||= Attributes.new
        end

        def set_create(mutation:, variables: {})
          @create_mutation = mutation
          @create_variables = variables
        end

        def set_update(mutation:, variables: {})
          @update_mutation = mutation
          @update_variables = variables
        end
      end

      def attributes
        model_attributes.each_with_object({}) do |attribute, memo|
          memo[attribute.name] = public_send(attribute.name)
        end
      end

      def create_variables
        instance_exec(&self.class.create_variables)
      end

      def update_variables
        instance_exec(&self.class.update_variables)
      end

      def save
        if id.nil?
          client.query(self.class.create_mutation, create_variables)
        else
          client.query(self.class.update_mutation, update_variables)
        end
      end

      private

      def model_attributes
        self.class.model_attributes
      end

      delegate :client, to: :class
    end
  end
end

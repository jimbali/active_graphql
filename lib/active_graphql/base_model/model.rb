# frozen_string_literal: true

require 'active_model'
require 'active_graphql/base_model/attributes'

module ActiveGraphql
  module BaseModel
    class Model
      include ActiveModel::Model
      include ActiveModel::AttributeMethods

      class << self
        attr_reader :create_variables

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
      end

      def attributes
        model_attributes.each_with_object({}) do |attribute, memo|
          memo[attribute.name] = public_send(attribute.name)
        end
      end

      def create_variables
        instance_exec(&self.class.create_variables)
      end

      private

      def model_attributes
        self.class.model_attributes
      end
    end
  end
end

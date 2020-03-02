# frozen_string_literal: true

require 'active_support/concern'
require 'active_graphql/base_model/attributes'

module ActiveGraphql
  module BaseModel
    module HasAttributes
      extend ActiveSupport::Concern

      class_methods do
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

        def attribute_names
          model_attributes.map { |attr| attr.name.to_s.camelize(:lower) }
        end
      end

      def attributes
        model_attributes.each_with_object({}) do |attribute, memo|
          memo[attribute.name] = public_send(attribute.name)
        end
      end

      private

      def model_attributes
        self.class.model_attributes
      end
    end
  end
end

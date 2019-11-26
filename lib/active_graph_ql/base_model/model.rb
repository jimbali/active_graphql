# frozen_string_literal: true

require 'active_model'
require 'active_graph_ql/base_model/attributes'

module ActiveGraphQl
  module BaseModel
    class Model
      include ActiveModel::Model
      include ActiveModel::AttributeMethods

      class << self
        def attribute(name, opts = {})
          attribute = add_attribute(name, opts)

          attr_accessor name
        end

        def add_attribute(name, opts)
          define_attribute_method(name)
          model_attributes.add(name, opts)
        end

        def model_attributes
          @model_attributes ||= Attributes.new
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

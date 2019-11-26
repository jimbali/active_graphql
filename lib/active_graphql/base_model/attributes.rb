# frozen_string_literal: true

require 'active_graphql/base_model/attribute'

module ActiveGraphql
  module BaseModel
    class Attributes
      include Enumerable

      attr_reader :attributes

      def initialize
        @attributes = []
      end

      def each(&block)
        @attributes.each(&block)
      end

      def add(name, opts = {})
        remove_attribute_if_duplicated(name)

        attribute = create_attribute(name, opts)

        name_field_mapping[name] = attribute.field_name

        @attributes << attribute

        attribute
      end

      private

      def create_attribute(name, opts)
        Attribute.new(name, opts)
      end

      def name_field_mapping
        @name_field_mapping ||= {}
      end

      def remove_attribute_if_duplicated(name)
        attributes.reject! { |a| a.name == name }
      end
    end
  end
end

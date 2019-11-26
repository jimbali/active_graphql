# frozen_string_literal: true

require 'active_support/inflector'

module ActiveGraphQl
  module BaseModel
    class Attribute
      attr_reader :name

      def initialize(name, opts = {})
        @name = name
        @opts = opts
      end

      def field_name
        @opts[:field_name] || name.to_s.titlecase.delete(' ').to_sym
      end

      private

      attr_reader :opts
    end
  end
end

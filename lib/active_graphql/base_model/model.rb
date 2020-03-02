# frozen_string_literal: true

require 'active_model'
require 'active_graphql/base_model/has_attributes'
require 'active_graphql/base_model/mutable'
require 'active_graphql/base_model/queryable'
require 'active_graphql/client'

module ActiveGraphql
  module BaseModel
    class Model
      include ActiveModel::Model
      include ActiveModel::AttributeMethods
      include BaseModel::HasAttributes
      include BaseModel::Mutable
      include BaseModel::Queryable

      class << self
        def client
          ActiveGraphql.client
        end

        def object_type(object_type = nil)
          @object_type = object_type if object_type
          @object_type ||= name
        end
      end

      delegate :client, to: :class
    end
  end
end

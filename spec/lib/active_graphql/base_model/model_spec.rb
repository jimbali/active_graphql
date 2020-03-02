# frozen_string_literal: true

require 'spec_helper'
require 'active_graphql/base_model/model'
require_relative '../../../support/has_attributes'
require_relative '../../../support/mutable'
require_relative '../../../support/queryable'

RSpec.describe ActiveGraphql::BaseModel::Model do
  it_behaves_like 'HasAttributes'
  it_behaves_like 'Mutable'
  it_behaves_like 'Queryable'
end

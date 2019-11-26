require 'spec_helper'
require 'active_graph_ql/base_model/model'

RSpec.describe ActiveGraphQl::BaseModel::Model do
  describe '#attributes' do
    let(:returned_attributes) do
      {
        id: nil,
        name: nil,
        domain_identifier: nil,
        security_domain: nil,
        internal: nil,
        blue_light: nil,
        partner: nil
      }
    end

    let(:model_klass) do
      Class.new(ActiveGraphQl::BaseModel::Model) do
        attribute :id
        attribute :name
        attribute :domain_identifier
        attribute :security_domain
        attribute :internal
        attribute :blue_light
        attribute :partner
      end
    end

    let(:model_instance) { model_klass.new }

    it 'returns the models attributes' do
      expect(model_instance.attributes).to eq(returned_attributes)
    end
  end
end

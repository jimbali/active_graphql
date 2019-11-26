# frozen_string_literal: true

require 'spec_helper'
require 'active_graphql/base_model/model'

RSpec.describe ActiveGraphql::BaseModel::Model do
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
      Class.new(ActiveGraphql::BaseModel::Model) do
        attribute :id
        attribute :name
        attribute :domain_identifier
        attribute :security_domain
        attribute :internal
        attribute :blue_light
        attribute :partner
      end
    end

    let(:model_instance) { model_klass.new(initial_attributes) }
    let(:initial_attributes) { {} }

    it 'returns the models attributes' do
      expect(model_instance.attributes).to eq(returned_attributes)
    end

    describe 'set an attribute' do
      let(:name) { 'Name1' }

      before { model_instance.name = name }

      it 'sets the right value' do
        expect(model_instance.name).to eq name
      end

      context 'with an initial attribute' do
        let(:initial_attributes) do
          { security_domain: security_domain }
        end

        let(:security_domain) { 'ASSURED' }

        it 'sets the right value' do
          expect(model_instance.security_domain).to eq security_domain
        end
      end
    end
  end
end

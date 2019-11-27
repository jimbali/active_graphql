# frozen_string_literal: true

require 'spec_helper'
require 'active_graphql/base_model/model'
require 'active_graphql/client'

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

    let(:create_mutation) do
      <<~GRAPHQL
        mutation CreateCompany($input: CreateCompanyInput!) {
          createCompany(input: $input) {
            company {
              id
              name
              domainIdentifier
              securityDomain
              internal
              blueLight
              partner
            }
          }
        }
      GRAPHQL
    end

    let(:create_variables) do
      -> {
        {
          input: {
            domainIdentifier: domain_identifier,
            name: name,
            securityDomain: security_domain,
            internal: internal,
            blueLight: blue_light,
            partner: partner
          }
        }
      }
    end

    let(:create_input) do
      {
        input: {
          domainIdentifier: 9000,
          name: 'Company1',
          securityDomain: 'ASSURED',
          internal: false,
          blueLight: false,
          partner: true
        }
      }
    end

    before do
      model_klass.set_create mutation: create_mutation,
                             variables: create_variables
    end

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

    describe 'mutations' do
      describe 'set the create mutation and variables' do
        let(:initial_attributes) do
          {
            id: 3,
            name: 'Company1',
            domain_identifier: 9000,
            security_domain: 'ASSURED',
            internal: false,
            blue_light: false,
            partner: true
          }
        end

        it 'generates the variables' do
          expect(model_instance.create_variables).to eq(create_input)
        end
      end
    end

    describe '#save' do
      context 'when the object has no ID' do
        let(:initial_attributes) do
          {
            name: 'Company1',
            domain_identifier: 9000,
            security_domain: 'ASSURED',
            internal: false,
            blue_light: false,
            partner: true
          }
        end

        let(:client) { instance_double(ActiveGraphql::Client) }

        before do
          allow(model_klass).to receive(:client).and_return(client)
          allow(client).to receive(:query)
        end

        it 'executes the create mutation' do
          model_instance.save
          expect(client).to have_received(:query).with(
            create_mutation, create_input
          )
        end
      end
    end
  end
end

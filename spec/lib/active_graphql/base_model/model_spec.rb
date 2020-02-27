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
      Company = Class.new(ActiveGraphql::BaseModel::Model) do
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
        mutation($input: CreateCompanyInput!) {
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
      lambda {
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

    let(:update_mutation) do
      <<~GRAPHQL
        mutation($input: UpdateCompanyInput!) {
          updateCompany(input: $input) {
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

    let(:update_variables) do
      lambda {
        {
          input: {
            id: id,
            name: name,
            internal: internal,
            blueLight: blue_light,
            partner: partner
          }
        }
      }
    end

    let(:update_input) do
      {
        input: {
          id: 3,
          name: 'Company2',
          internal: true,
          blueLight: true,
          partner: false
        }
      }
    end

    before do
      model_klass.set_create mutation: create_mutation,
                             variables: create_variables
      model_klass.set_update mutation: update_mutation,
                             variables: update_variables
    end

    it 'returns the models attributes' do
      expect(model_instance.attributes).to eq(returned_attributes)
    end

    it 'generates the object type' do
      expect(model_instance.object_type).to eq('Company')
    end

    context 'when suppling an object type' do
      before { model_klass.object_type 'Account' }

      it 'uses the supplied the object type' do
        expect(model_instance.object_type).to eq('Account')
      end
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

      describe 'set the create mutation and variables' do
        it 'generates the variables' do
          expect(model_instance.create_variables).to eq(create_input)
        end
      end

      describe 'set the update mutation and variables' do
        before do
          model_instance.name = 'Company2'
          model_instance.partner = false
          model_instance.blue_light = true
          model_instance.internal = true
        end

        it 'generates the variables' do
          expect(model_instance.update_variables).to eq(update_input)
        end
      end
    end

    describe '#save' do
      let(:client) { instance_double(ActiveGraphql::Client) }

      let(:result) do
        { 'data' => { mutation_name => { 'company' => returned_object } } }
      end

      let(:returned_object) do
        {
          'id' => generated_id,
          'name' => 'Company1',
          'domainIdentifier' => 9000,
          'securityDomain' => 'ASSURED',
          'internal' => false,
          'blueLight' => false,
          'partner' => true
        }
      end

      let(:generated_id) { Random.rand(1..100) }

      before do
        allow(model_klass).to receive(:client).and_return(client)
        allow(client).to receive(:query).and_return(result)
      end

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

        let(:mutation_name) { 'createCompany' }

        it 'executes the create mutation' do
          model_instance.save
          expect(client).to have_received(:query).with(
            create_mutation, create_input
          )
        end

        it 'sets the ID to the newly created one' do
          model_instance.save
          expect(model_instance.id).to eq generated_id
        end

        context 'with a custom result path' do
          let(:result) do
            { 'myMutation' => { 'myObject' => returned_object } }
          end

          before do
            model_klass.create_result_path %w[myMutation myObject]
          end

          it 'sets the ID to the newly created one' do
            model_instance.save
            expect(model_instance.id).to eq generated_id
          end
        end
      end

      context 'when the object has an ID' do
        let(:initial_attributes) do
          {
            id: 3,
            name: 'Company2',
            domain_identifier: 9000,
            security_domain: 'ASSURED',
            internal: true,
            blue_light: true,
            partner: false
          }
        end

        let(:mutation_name) { 'updateCompany' }

        it 'executes the update mutation' do
          model_instance.save
          expect(client).to have_received(:query).with(
            update_mutation, update_input
          )
        end
      end
    end
  end
end

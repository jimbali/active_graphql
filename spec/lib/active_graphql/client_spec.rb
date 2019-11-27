# frozen_string_literal: true

require 'spec_helper'
require 'active_graphql/client'
require 'oauth2_autorenew/access_token'

RSpec.describe ActiveGraphql::Client do
  let(:mutation) do
    <<~GRAPHQL
      mutation {
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

  let(:variables) do
    {
      input: {
        domainIdentifier: 1,
        name: 'Company1',
        securityDomain: 'ASSURED',
        internal: false,
        blueLight: false,
        partner: true
      }
    }
  end

  let(:instance) { described_class.new(access_token, graphlient: graphlient) }
  let(:access_token) { instance_double(Oauth2Autorenew::AccessToken) }
  let(:graphlient) { instance_double(Graphlient::Client) }

  describe 'run a query' do
    let(:response) { instance_double(GraphQL::Client::Response) }

    let(:response_data) do
      {
        data: {
          createCompany: {
            company: {
              id: 322,
              name: 'JimbaliTest',
              domainIdentifier: 9000,
              securityDomain: 'ASSURED',
              internal: false,
              blueLight: false,
              partner: true
            }
          }
        }
      }
    end

    before do
      allow(graphlient).to receive(:execute).and_return(response)
      allow(response).to receive(:errors).and_return([])
      allow(response).to receive(:original_hash).and_return(response_data)
    end

    it 'executes the query in graphlient' do
      instance.query(mutation, variables)
      expect(graphlient).to have_received(:execute).with(mutation, variables)
    end
  end
end

# frozen_string_literal: true

require 'active_graphql/oauth2_autorenew_adapter.rb'
require 'oauth2_autorenew/access_token'

RSpec.describe ActiveGraphql::Oauth2AutorenewAdapter do
  let(:access_token) { instance_double(Oauth2Autorenew::AccessToken) }
  let(:instance) { described_class.new(url) }
  let(:url) { 'http://localhost:3005/api' }

  before { described_class.configure(access_token: access_token) }

  describe 'self.configure' do
    it 'stores the access token' do
      expect(described_class.access_token).to eq access_token
    end
  end

  describe '#execute' do
    let(:document) do
      instance_double(
        GraphQL::Language::Nodes::Document,
        to_query_string: query_string
      )
    end

    let(:query_string) { 'query { companies { id } }' }
    let(:variables) { { id: 1 } }
    let(:body) { { query: query_string, variables: variables }.to_json }
    let(:headers) { { 'Content-Type' => 'application/json' } }
    let(:results) { { 'data' => { 'companies' => [{ 'id' => 1 }] } } }

    let(:response) do
      instance_double(
        OAuth2::Response,
        body: results.to_json
      )
    end

    before do
      allow(access_token).to receive(:post_and_retry).and_return(response)
    end

    it 'uses the access token to run the query' do
      instance.execute(document: document, variables: variables)
      expect(access_token).to have_received(:post_and_retry).with(
        body, headers: headers
      )
    end

    it 'returns the parsed response' do
      expect(instance.execute(document: document, variables: variables))
        .to eq results
    end

    context 'when an error occurs' do
      let(:error) do
        OAuth2::Error.new(instance_double(OAuth2::Response).as_null_object)
      end

      before do
        allow(access_token).to receive(:post_and_retry)
          .with(body, headers: headers)
          .and_raise(error)
      end

      it 'raises an error' do
        expect { instance.execute(document: document, variables: variables) }
          .to raise_error(ActiveGraphql::Oauth2ServerError)
      end
    end
  end
end

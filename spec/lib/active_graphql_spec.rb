# frozen_string_literal: true

require 'spec_helper'
require 'oauth2_autorenew/access_token'

RSpec.describe ActiveGraphql do
  describe '.client' do
    let(:access_token) { instance_double(Oauth2Autorenew::AccessToken) }
    let(:graphlient) { instance_double(Graphlient::Client) }
    let(:client) { instance_double(ActiveGraphql::Client) }

    before do
      ActiveGraphql.instance_variable_set(:@client, nil)
      ActiveGraphql.configure(access_token, graphlient: graphlient)
      allow(ActiveGraphql::Client)
        .to receive(:new)
        .with(access_token, graphlient: graphlient)
        .and_return(client)
    end

    after do
      ActiveGraphql.instance_variable_set(:@client, nil)
    end

    it 'returns the configured client' do
      expect(ActiveGraphql.client).to be client
    end
  end
end

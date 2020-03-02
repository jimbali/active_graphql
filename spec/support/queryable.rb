# frozen_string_literal: true

require 'spec_helper'

RSpec.shared_examples 'Queryable' do
  include_context 'active_graphql'

  describe '.all' do
    include_context 'active_graphql'

    let(:result) do
      { 'data' => { 'companies' => returned_array } }
    end

    let(:returned_array) do
      [
        {
          'id' => 1,
          'name' => 'Company1',
          'domainIdentifier' => 9000,
          'securityDomain' => 'ASSURED',
          'internal' => false,
          'blueLight' => false,
          'partner' => true
        }
      ]
    end

    before do
      allow(client).to receive(:query).and_return(result)
    end

    it 'returns the array of objects' do
      expect(model_klass.all).to eq(returned_array)
    end

    context 'with a custom result path' do
      let(:result) do
        { 'myObjects' => returned_array }
      end

      before do
        model_klass.query_result_path %w[myObjects]
      end

      it 'returns the array of objects' do
        expect(model_klass.all).to eq(returned_array)
      end
    end
  end
end

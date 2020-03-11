# frozen_string_literal: true

require 'spec_helper'

RSpec.shared_examples 'Queryable' do
  include_context 'model'

  context 'with a filter' do
    let(:model_klass) do
      Class.new(ActiveGraphql::BaseModel::Model) do
        object_type 'User'

        attribute :id
        attribute :name
        attribute :email

        filter :name, types[!types.String]
      end
    end

    let(:types) { GraphQL::Define::TypeDefiner.instance }

    let(:filtered_query) do
      <<~GRAPHQL
        query($name: [String!]) {
          users(name: $name) {
            id name email
          }
        }
      GRAPHQL
    end

    describe '.generate_query' do
      it 'generates the query based on defaults' do
        expect(model_klass.generate_query).to eq(filtered_query)
      end
    end

    describe '.find_by!' do
      let(:filtered_result) do
        { 'data' => { 'users' => filtered_array } }
      end

      let(:filtered_array) do
        [
          {
            'id' => 2,
            'name' => 'User2',
            'email' => 'lord_snooty@beano.com'
          }
        ]
      end

      let(:variables) { { name: 'User2' } }

      before do
        allow(client)
          .to receive(:query)
          .with(filtered_query, variables)
          .and_return(filtered_result)
      end

      it 'returns the filtered results' do
        expect(model_klass.find_by!(**variables)).to eq filtered_array
      end
    end
  end

  describe '.all' do
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

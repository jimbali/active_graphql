# frozen_string_literal: true

RSpec.describe ActiveGraphql::Oauth2ServerError do
  let(:response) do
    instance_double(OAuth2::Response, status: 401).as_null_object
  end

  let(:original_error) do
    OAuth2::Error.new(response)
  end

  let(:error) { described_class.new(original_error) }

  it 'returns the original error' do
    expect(error.inner_exception).to eq original_error
  end

  it 'returns the response' do
    expect(error.response).to eq response
  end

  it 'returns the status code' do
    expect(error.status_code).to eq 401
  end
end

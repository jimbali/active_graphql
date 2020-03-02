# frozen_string_literal: true

require 'simplecov'
require 'simplecov-console'
require 'simplecov-html'

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new(
  [SimpleCov::Formatter::HTMLFormatter, SimpleCov::Formatter::Console]
)

SimpleCov.start

require 'active_graphql'

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.filter_run_when_matching :focus
  config.example_status_persistence_file_path = 'spec/examples.txt'
  config.disable_monkey_patching!
  config.warnings = true
  config.default_formatter = 'doc' if config.files_to_run.one?
  config.order = :random
  Kernel.srand config.seed
end

class Company < ActiveGraphql::BaseModel::Model
  attribute :id
  attribute :name
  attribute :domain_identifier
  attribute :security_domain
  attribute :internal
  attribute :blue_light
  attribute :partner
end

RSpec.shared_context 'model' do
  let(:client) { instance_double(ActiveGraphql::Client) }
  let(:model_klass) { Company }
  let(:model_instance) { model_klass.new(initial_attributes) }
  let(:initial_attributes) { {} }

  before do
    allow(model_klass).to receive(:client).and_return(client)
  end
end

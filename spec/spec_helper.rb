ENV['RAILS_ENV'] ||= 'test'

# Gems
require File.expand_path('../../config/environment', __FILE__)
require 'rspec/rails'
require 'webmock/rspec'

# Shared
require 'shared'

RSpec.configure do |config|

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.before(:suite) do
    FactoryGirl.find_definitions
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
end

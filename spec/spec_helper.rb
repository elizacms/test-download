# Config
require 'shared/config'

# Gems
require File.expand_path('../../config/environment', __FILE__)
require 'rspec/rails'
require 'capybara/rspec'
require 'webmock/rspec'

# Shared
require 'shared'
require 'http_mocks/identity_mock'

Mongoid.logger.level = Logger::ERROR

WebMock.disable_net_connect!( allow_localhost:true )

Capybara.javascript_driver = :selenium

RSpec.configure do |config|
  config.include Rack::Test::Methods
  config.include Capybara::DSL
  config.include FactoryGirl::Syntax::Methods

  config.filter_run_including focus: true
  config.run_all_when_everything_filtered = true
  config.infer_spec_type_from_file_location!

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups

  config.backtrace_exclusion_patterns = [
    /gems/
  ]

  config.before(:all) do
    # Fix issue with browser hanging on first spec
    visit '/'
    # sleep 1
    execute_script( 'window.reload();' ) if Capybara.current_driver == Capybara.javascript_driver
  end

  config.before(:each) do
    Mongoid.purge!
    ActionMailer::Base.deliveries = []
  end
end

def app
  Capybara.app
end

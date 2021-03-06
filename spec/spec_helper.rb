# Config
require 'shared/config'


# Gems
require File.expand_path('../../config/environment', __FILE__)
require 'rspec/rails'
require 'capybara/rspec'
require 'webmock/rspec'
require 'sidekiq/testing'


# Shared
require 'shared'
require 'http_mocks/identity_mock'
require 'http_mocks/jenkins_mock'


Mongoid.logger.level = Logger::ERROR
WebMock.disable_net_connect!( allow_localhost:true )
Capybara.javascript_driver = :selenium
Sidekiq::Testing.inline!

RSpec.configure do |config|
  config.include Rack::Test::Methods
  config.include Capybara::DSL
  config.include FactoryGirl::Syntax::Methods
  config.include FilePath

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

  config.before(:each) do
    FileUtils.rm_rf( ENV['NLU_CMS_PERSISTENCE_PATH'] )
    I18n.default_locale = 'en'
    Mongoid.purge!

    Dir.mkdir( ENV['NLU_CMS_PERSISTENCE_PATH'] )
    Dir.mkdir( "#{ENV['NLU_CMS_PERSISTENCE_PATH']}/eliza_de/" )
    Dir.mkdir( "#{ENV['NLU_CMS_PERSISTENCE_PATH']}/eliza_de/actions" )
    Dir.mkdir( "#{ENV['NLU_CMS_PERSISTENCE_PATH']}/intent_responses_csv" )
    Dir.mkdir( "#{ENV['NLU_CMS_PERSISTENCE_PATH']}/training_data" )
    Dir.mkdir( "#{ENV['NLU_CMS_PERSISTENCE_PATH']}/raw_knowledge" )
    Dir.mkdir( "#{ENV['NLU_CMS_PERSISTENCE_PATH']}/raw_knowledge/entity_data" )
    Dir.mkdir( "#{ENV['NLU_CMS_PERSISTENCE_PATH']}/stop_words" )

    FileUtils.mkpath( "#{ENV['NLU_CMS_PERSISTENCE_PATH']}/language_rule_csv/de" )
    File.write( single_word_rule_file,
                File.read('spec/data-files/german-intents-singleword-rules.csv') )
    File.write( stop_words_file,
                File.read('spec/data-files/stop-words.txt') )

    Rugged::Repository.init_at( ENV['NLU_CMS_PERSISTENCE_PATH'] )
    ActionMailer::Base.deliveries = []
  end
end

def app
  Capybara.app
end

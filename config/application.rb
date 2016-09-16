require_relative 'boot'

require "rails"

%w(
  action_controller
  action_mailer
  active_resource
).each do |framework|
  begin
    require "#{framework}/railtie"
  rescue LoadError
  end
end

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module SkillsManager
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    config.mongoid.logger = Logger.new($stdout, :warn)

    config.force_ssl = true
  end
end

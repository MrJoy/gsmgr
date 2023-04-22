# frozen_string_literal: true

require_relative "boot"

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
# require "active_job/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
# require "action_mailbox/engine"
# require "action_text/engine"
require "action_view/railtie"
# require "action_cable/engine"
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, :docker, :stage, or :prod.
Bundler.require(*Rails.groups)

Dotenv::Railtie.overload
# N.B. Not really sure this is prudent, and won't interact badly with the railtie, but...
if ENV["CREDENTIALS_DIRECTORY"]
  Dotenv.load(File.join(ENV.fetch("CREDENTIALS_DIRECTORY", nil), ".env"))
else
  Dotenv.load
end

module Core
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    # config.autoload_paths << Rails.root.join('lib')
    # config.eager_load_paths << Rails.root.join('lib')

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    config.generators do |gen|
      gen.system_tests        false
      gen.scaffold_stylesheet false
      gen.fixture_replacement :factory_bot
      gen.factory_bot         dir: "spec/factories"
      gen.stylesheets         false
      gen.javascripts         false
      gen.helper              false
      gen.test_framework      :rspec, fixture: true
      gen.integration_tool    :rspec
      gen.performance_tool    :rspec
    end
  end
end

# Rails.autoloaders.log!

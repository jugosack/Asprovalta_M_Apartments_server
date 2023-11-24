require_relative "boot"

require "rails/all"


# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module AsprovaltaMApartmentsServer
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0
  
    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
  config.api_only = true
  # config.middleware.use ActionDispatch::ContentNegotiation, formats: { json: :json }
  config.secret_key_base = '27b964f24e0cd78a7f96b52b1327ce8583bf5ef04e2e2ced72b332969ccf83009185df06dd12c9eb9b39a444136e61d17ebbcbd7956e6d397d65159ee8293b21'

  config.middleware.use ActionDispatch::Flash

  config.session_store :cookie_store, key: '_interslice_session'
    config.middleware.use ActionDispatch::Cookies
   
    config.middleware.use config.session_store, config.session_options

    config.log_path = "log/server.log"

   
    config.action_dispatch.default_headers = {
      'X-Frame-Options' => 'ALLOWALL'
    }
  end
end

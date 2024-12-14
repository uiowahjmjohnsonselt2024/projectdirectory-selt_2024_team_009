require "active_support/core_ext/integer/time"

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Code is not reloaded between requests.
  config.enable_reloading = false
  config.web_socket_server_url = "wss://shards-of-the-grid-team-09.herokuapp.com/cable"
  # config/environments/production.rb
  config.action_cable.url = 'wss://shards-of-the-grid-team-09.herokuapp.com/cable'
  config.action_cable.allowed_request_origins = [
    'https://shards-of-the-grid-team-09.herokuapp.com',
    'http://shards-of-the-grid-team-09.herokuapp.com'
  ]
  config.action_cable.worker_pool_size = 10


  # Eager load code on boot.
  config.eager_load = true
  config.serve_static_assets = true

  # Full error reports are disabled and caching is turned on.
  config.consider_all_requests_local = false
  config.action_controller.perform_caching = true
  config.secret_key_base = Rails.application.credentials.secret_key_base

  # Log to STDOUT by default
  config.logger = ActiveSupport::Logger.new(STDOUT)
                                       .tap  { |logger| logger.formatter = ::Logger::Formatter.new }
                                       .then { |logger| ActiveSupport::TaggedLogging.new(logger) }
  # Only use :id for inspections in production.
  config.active_record.attributes_for_inspect = [ :id ]
  # Ensure encrypted credentials
  config.require_master_key = true

  # Force all access to the app over SSL
  config.force_ssl = true

  # Host and protocol settings
  host = ENV["DEFAULT_URL_HOST"] || "#{ENV['HEROKU_APP_NAME']}.herokuapp.com"
  protocol = config.force_ssl ? "https" : "http"
  config.action_controller.default_url_options = { host: host, protocol: protocol }

  # Log level and tags
  config.log_level = :debug
  config.log_tags = [:request_id]

  # Enable locale fallbacks for I18n
  config.i18n.fallbacks = true

  # Notify listeners of deprecations
  config.active_support.deprecation = :notify

  # Disable schema dump after migrations
  config.active_record.dump_schema_after_migration = false

  # Action Mailer settings for Devise in production
  config.action_mailer.default_url_options = { host: host, protocol: protocol }
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
    address:              'smtp.gmail.com',
    port:                 587,
    domain:               'yourdomain.com',           # Replace with your actual domain
    user_name:            ENV['GMAIL_USERNAME'],      # Set this in your environment variables
    password:             ENV['GMAIL_PASSWORD'],      # Set this in your environment variables
    authentication:       'plain',
    enable_starttls_auto: true
  }
end

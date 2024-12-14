# config/environments/production.rb
require "active_support/core_ext/integer/time"

Rails.application.configure do
  # Settings specified here take precedence over those in config/application.rb.

  # Mount path for Action Cable
  config.action_cable.mount_path = '/cable'

  # Code is not reloaded between requests
  config.enable_reloading = false

  # WebSocket server URL
  config.web_socket_server_url = "wss://shards-of-the-grid-team-09.herokuapp.com/cable"

  # Action Cable URL and allowed request origins
  config.action_cable.url = 'wss://shards-of-the-grid-team-09.herokuapp.com/cable'
  config.action_cable.allowed_request_origins = [
    'https://shards-of-the-grid-team-09.herokuapp.com',
    'https://rubyonrails.com',
    %r{http://ruby.*}
  ]
  config.action_cable.worker_pool_size = 10

  # Eager load code on boot
  config.eager_load = true
  config.serve_static_assets = true

  # Full error reports are disabled
  config.consider_all_requests_local = false
  config.action_controller.perform_caching = true
  config.secret_key_base = Rails.application.credentials.secret_key_base

  # Logging configuration
  config.logger = ActiveSupport::Logger.new(STDOUT)
                                       .tap  { |logger| logger.formatter = ::Logger::Formatter.new }
                                       .then { |logger| ActiveSupport::TaggedLogging.new(logger) }
  config.log_level = :debug
  config.log_tags = [:request_id]

  # Ensure encrypted credentials
  config.require_master_key = true

  # Force SSL in production
  config.force_ssl = true

  # Host and protocol
  host = ENV["DEFAULT_URL_HOST"] || "shards-of-the-grid-team-09.herokuapp.com"
  protocol = config.force_ssl ? "https" : "http"
  config.action_controller.default_url_options = { host: host, protocol: protocol }

  # Internationalization fallbacks
  config.i18n.fallbacks = true

  # Deprecation notices
  config.active_support.deprecation = :notify

  # Don't dump schema after migrations
  config.active_record.dump_schema_after_migration = false

  # Action Mailer settings for Devise
  config.action_mailer.default_url_options = { host: host, protocol: protocol }
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
    address:              'smtp.gmail.com',
    port:                 587,
    domain:               'yourdomain.com', # Replace with your actual domain
    user_name:            ENV['GMAIL_USERNAME'],
    password:             ENV['GMAIL_PASSWORD'],
    authentication:       'plain',
    enable_starttls_auto: true
  }
end

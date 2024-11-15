require "active_support/core_ext/integer/time"

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Code is not reloaded between requests.
  config.enable_reloading = false

  # Eager load code on boot.
  config.eager_load = true

  # Full error reports are disabled and caching is turned on.
  config.consider_all_requests_local = false
  config.action_controller.perform_caching = true
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
end



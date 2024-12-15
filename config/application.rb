require_relative "boot"

require "rails/all"
# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Dotenv.load(".env.#{Rails.env}") if defined?(Dotenv)

Bundler.require(*Rails.groups)

module ProjectdirectorySelt2024Team009
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.2

    # Ensure encrypted credentials are required
    config.require_master_key = true
    config.assets.paths << Rails.root.join('app', 'assets', 'images')

    # Automatically load lib subdirectories
    config.autoload_lib(ignore: %w[assets tasks])
    # **Development-Specific Configurations**
    if Rails.env.development?
      # Enable debug mode for Action Cable to get detailed logs
      config.action_cable.disable_request_forgery_protection = true
    end

    # **Production-Specific Configurations**
    if Rails.env.production?
      # Use Redis adapter for Action Cable in production
      config.action_cable.url = ENV['ACTION_CABLE_URL'] || "wss://shards-of-the-grid-team-09-ad424e75e121.herokuapp.com/cable"
      config.action_cable.allowed_request_origins = [
        'https://shards-of-the-grid-team-09-ad424e75e121.herokuapp.com',
        'https://rubyonrails.com',
        %r{http://ruby.*}
      ]
    end
    # config.autoloader = :classic
    # Example of adding additional paths for eager loading
    # config.eager_load_paths << Rails.root.join("extras")
    config.eager_load_paths << Rails.root.join('lib')
  end
end
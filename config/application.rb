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
    config.autoloader = :classic
    # Example of adding additional paths for eager loading
    # config.eager_load_paths << Rails.root.join("extras")
  end
end
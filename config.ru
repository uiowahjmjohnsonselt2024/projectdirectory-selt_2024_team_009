require_relative "config/environment"
Rails.application.eager_load!

# Serve the entire Rails app, including ActionCable
run Rails.application

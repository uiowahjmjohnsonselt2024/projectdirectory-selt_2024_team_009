# This file is used by Rack-based servers to start the application.

require_relative "config/environment"
Rails.application.eager_load!

run ActionCable.server

#
# run Rails.application
# Rails.application.load_server

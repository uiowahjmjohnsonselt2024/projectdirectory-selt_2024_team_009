# Puma configuration file

# Default threads configuration
threads_count = ENV.fetch("RAILS_MAX_THREADS", 5).to_i
threads threads_count, threads_count

# Determine environment
environment ENV.fetch("RAILS_ENV", "development")

# Configure per environment
case ENV.fetch("RAILS_ENV", "development")
when "development"
  # Development-specific settings
  port ENV.fetch("PORT", 3000)
  pidfile ENV.fetch("PIDFILE", "tmp/pids/server_dev.pid")
  plugin :tmp_restart
when "test"
  # Test-specific settings
  port ENV.fetch("PORT", 3001)
  pidfile ENV.fetch("PIDFILE", "tmp/pids/server_test.pid")
  plugin :tmp_restart
when "production"
  # Production-specific settings
  workers ENV.fetch("WEB_CONCURRENCY", 2)
  preload_app!

  # Heroku requires binding to 0.0.0.0
  bind "tcp://0.0.0.0:#{ENV.fetch('PORT', 3002)}"
  pidfile ENV.fetch("PIDFILE", "tmp/pids/server_prod.pid")

  # Enable cluster mode for performance
  on_worker_boot do
    ActiveRecord::Base.establish_connection if defined?(ActiveRecord)
  end

  # Explicitly allow tmp_restart for Heroku compatibility
  plugin :tmp_restart
else
  raise "Unknown environment: #{ENV['RAILS_ENV']}"
end

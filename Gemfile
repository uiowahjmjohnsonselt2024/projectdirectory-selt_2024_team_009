# Specify the minimum bundler version
gem "bundler", "~> 2.5"

source "https://rubygems.org"

ruby "3.3.0"

# Rails framework
gem "rails", "~> 7.2.2"

# Database adapters
gem "pg", "~> 1.5", group: :production # PostgreSQL for production
gem "sqlite3", "~> 2.2", groups: [ :development, :test ] # SQLite for development and test

# Web server interface for Ruby/Rack applications
gem "puma", "~> 6"

# Asset pipeline
gem "propshaft" # Modern asset pipeline for Rails
gem "sprockets-rails" # For compatibility with older assets

# Frontend libraries
gem "importmap-rails" # Use ESM with import maps
gem "turbo-rails" # Hotwire's Turbo for SPA-like experience
gem "stimulus-rails" # Hotwire's Stimulus for JavaScript framework
gem "sass-rails", "~> 6.0" # Use Sass for stylesheets
gem "uglifier", "~> 4.2" # JavaScript compressor
gem "coffee-rails", "~> 5.0" # Use CoffeeScript for .coffee assets
gem "jquery-rails" # Use jQuery as the JavaScript library
gem "haml" # Use Haml as the templating engine
gem "cancancan" # Authorization library
# JSON APIs
gem "jbuilder", "~> 2.13"
gem 'haml-rails'
# Authentication
gem "devise", "~> 4.9"
gem "bcrypt", "~> 3.1.7" # Password hashing
gem 'erb2haml'

# Redis support (optional)
# gem 'redis', '~> 4.7'
# gem 'kredis' # Higher-level data types in Redis

# Performance enhancements
gem "bootsnap", require: false # Reduces boot times through caching

# Debugging tools
gem "debug", platforms: %i[mri mingw x64_mingw], require: "debug/prelude"
gem "byebug", platforms: %i[mri mingw x64_mingw] # Debugger for Ruby

# Background jobs and caching (optional)
# gem 'solid_cache'
# gem 'solid_queue'
# gem 'solid_cable'

# Heroku deployment
gem "rails_12factor", group: :production

group :development, :test do
  # Testing frameworks
  gem "rspec-rails" # RSpec for Rails
  gem "factory_bot_rails" # Fixtures replacement
  gem "fixtures" # For fixtures
  gem "capybara", "~> 3.37" # Integration testing tool
  gem "selenium-webdriver" # Browser automation
  gem "simplecov", require: false # Code coverage analysis
  gem "database_cleaner-active_record" # Database cleaning strategies
  gem "webdrivers", "5.3.1" # Automatically downloads drivers for browser automation
  gem "launchy" # Opens URLs in testing
  gem "guard-rspec" # Automatically run specs when files are modified
  gem "rspec-expectations" # Express expected outcomes in examples
  gem "cucumber-rails", require: false # BDD for Rails applications
  gem "rubocop-rails-omakase", require: false
end

group :development do
  # Console enhancements
  gem "web-console" # Debugging tool for Rails
end

group :test do
  # Additional testing tools
  gem "database_cleaner" # Database cleaning strategies
end

# Code quality tools
gem "rubocop", require: false # Ruby static code analyzer
gem "rubocop-rails", require: false # Rails-specific linter rules
gem "brakeman", require: false # Security vulnerability scanner for Rails

# Documentation
gem "sdoc", "~> 2.6", group: :doc # Generate API documentation

# Spring application preloader
group :development do
  gem "spring" # Speeds up development by keeping the application running in the background
end



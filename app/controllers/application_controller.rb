# app/controllers/application_controller.rb

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  # Configure additional parameters for Devise
  before_action :configure_permitted_parameters, if: :devise_controller?
  # Capture and log flash messages (optional, for debugging)
  before_action :log_flash_messages

  protected
  def after_sign_in_path_for(resource)
    # 'user_root_path' is the path of the user's profile directory
    user_root_path(resource)
  end

  def configure_permitted_parameters
    # Permit additional fields for sign up and account update
    devise_parameter_sanitizer.permit(:sign_up, keys: %i[username])
    devise_parameter_sanitizer.permit(:account_update, keys: %i[username])
  end
  
  def after_sign_out_path_for(resource_or_scope)
    # 'root_path' is the path of the app's home directory
    root_path
  end

  def log_flash_messages
    Rails.logger.debug "Flash contents: #{flash.to_hash}" if flash.any?
  end
end

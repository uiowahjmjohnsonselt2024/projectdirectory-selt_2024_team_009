# app/controllers/application_controller.rb

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  # Configure additional parameters for Devise
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected
  def after_sign_in_path_for(resource)
    authenticated_root_path
  end

  def configure_permitted_parameters
    # Permit additional fields for sign up and account update
    devise_parameter_sanitizer.permit(:sign_up, keys: %i[username])
    devise_parameter_sanitizer.permit(:account_update, keys: %i[username])
  end
  def after_sign_out_path_for(resource_or_scope)
    unauthenticated_root_path
  end
end

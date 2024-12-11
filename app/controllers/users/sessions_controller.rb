# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  # before_action :configure_sign_in_params, only: [:create]

  # POST /resource/sign_in
  def create
    super
    if current_user
      # Generate a new cable_token only if it doesn't exist
      current_user.update!(cable_token: SecureRandom.hex(16)) if current_user.cable_token.blank?
    end
  end

  # DELETE /resource/sign_out
  def destroy
    if current_user
      # Optionally clear the token to invalidate any remaining sessions
      current_user.update!(cable_token: nil)
      sign_out current_user
      redirect_to root_path, notice: 'Signed out successfully.'
    end
    super # Calls the default Devise sign-out behavior
  end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  # end
end

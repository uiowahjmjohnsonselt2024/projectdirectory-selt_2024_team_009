# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  def create
    super
    cookies.signed[:cable_token] = { value: @user.cable_token, httponly: true }
  rescue => e
    Rails.logger.error("Error during sign-in: #{e.message}")
    redirect_to new_user_session_path, alert: "Unable to sign in."
  end
end

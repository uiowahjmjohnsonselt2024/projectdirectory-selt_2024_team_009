# app/controllers/profiles_controller.rb

class ProfilesController < ApplicationController
  before_action :authenticate_user!

  def show
    @user = current_user
    # Load additional resources as needed
  end
  def checkPass(username, password)

    user = User.find_by(username: username)

    if user && BCrypt::Password.new(user.encrypted_password) == password
      true
    else
      false
    end
  end
end

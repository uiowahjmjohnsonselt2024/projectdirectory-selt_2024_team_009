# app/controllers/profiles_controller.rb

class ProfilesController < ApplicationController
  before_action :authenticate_user!

  def show
    @user = current_user
    # Load additional resources as needed
  end

  def changePass(username, email, passToken, newPassword)

    user = User.find_by(username: username)
    if(email == User.find_by(email: user.email) && passToken == User.find_by(reset_password_token: user.reset_password_token))
      user.update(password: newPassword)
    end
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

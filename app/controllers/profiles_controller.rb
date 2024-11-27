# app/controllers/profiles_controller.rb
class ProfilesController < ApplicationController
  before_action :authenticate_user!

  # GET /profile/edit
  def edit
    @user = current_user
  end

  # GET /profile
  def show
    @user = current_user
  end

  # PUT /profile
  def update
    @user = current_user
    if @user.update(user_params)
      redirect_to authenticated_root_path, notice: 'Profile updated successfully.'
    else
      render :edit
    end
  end

  private

  def user_params
    params.require(:user).permit(:username, :email, :password, :password_confirmation, :role)
  end
end
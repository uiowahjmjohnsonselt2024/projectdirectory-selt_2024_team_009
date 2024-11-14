# app/controllers/profiles_controller.rb

class ProfilesController < ApplicationController
  before_action :authenticate_user!

  def show
    @user = current_user
    # Load additional resources as needed
  end
end

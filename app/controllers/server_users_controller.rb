class ServerUsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_server_user, only: %i[show edit update destroy]

  # GET /server_users
  def index
    @server_users = current_user.server_users.includes(:server)
  end

  # GET /server_users/:id
  def show
  end

  # GET /server_users/new
  def new
    @server_user = current_user.server_users.build
  end

  # POST /server_users
  def create
    @server_user = current_user.server_users.build(server_user_params)
    if @server_user.save
      redirect_to @server_user, notice: 'Joined server successfully.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /server_users/:id/edit
  def edit
  end

  # PATCH/PUT /server_users/:id
  def update
    if @server_user.update(server_user_params)
      redirect_to @server_user, notice: 'Server user was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /server_users/:id
  def destroy
    @server_user.destroy
    redirect_to server_users_url, notice: 'Left server successfully.'
  end

  private

  def set_server_user
    @server_user = current_user.server_users.find(params[:id])
  end

  def server_user_params
    params.require(:server_user).permit(:server_id, :current_position_x, :current_position_y)
  end
end

class ServerUsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_server_user, only: %i[destroy]

  # POST /server_users
  def create
    @server = Server.find(params[:server_id])

    if @server.users.include?(current_user)
      redirect_to @server, alert: 'You have already joined this game.'
      return
    end

    if @server.server_users.count >= @server.max_players
      redirect_to @server, alert: 'Server is full.'
      return
    end

    @server_user = @server.server_users.create(user: current_user)
    redirect_to @server, notice: 'You have joined the game.'
  end

  # DELETE /server_users/:id
  def destroy
    @server_user.destroy
    redirect_to servers_path, notice: 'You have left the game.'
  end

  private

  def set_server_user
    @server_user = current_user.server_users.find(params[:id])
  end
end

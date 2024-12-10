class ServerUsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_server_user, only: %i[destroy]
  before_action :set_server, only: %i[create]

  # POST /server_users
  def create
    if @server.users.include?(current_user)
      redirect_to @server, alert: 'You have already joined this game.'
      return
    end

    if @server.server_users.count >= @server.max_players
      redirect_to @server, alert: 'Server is full.'
      return
    end

    @server_user = @server.server_users.create(user: current_user)
    @server.assign_symbols_and_turn_order

    redirect_to @server, notice: 'You have joined the game.'
  end
  # DELETE /server_users/:id
  def destroy
    if @server.creator == current_user
      @server.destroy
      redirect_to servers_url, notice: 'Server was successfully destroyed.'
    else
      redirect_to servers_url, alert: 'You are not authorized to delete this server.'
    end
  end

  private

  def set_server_user
    @server_user = current_user.server_users.find(params[:id])
  end
  def set_server
    @server = Server.find(params[:server_id])
  end
end
class ServerUsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_server_user, only: %i[destroy]
  before_action :set_server, only:  %i[create leave]

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

    @server_user = @server.server_users.create(user: current_user, cable_token: current_user.cable_token)
    Rails.logger.info "[ServersController#join_game] User #{current_user.username} joined server #{@server.id} with cable_token: #{@server_user.cable_token}"
    @server.assign_symbols_and_turn_order
    @server.assign_starting_positions(new_user: @server_user)

    broadcast_game_update
    redirect_to server_game_path(@server, @server.game), notice: 'You have joined the game.'
  end

  def leave
    @server_user = current_user.server_users.find_by(server_id: params[:server_id])
    if @server_user
      @server = @server_user.server

      @server_user.destroy

      if @server.status == 'pending'
        @server.assign_symbols_and_turn_order
        @server.assign_starting_positions
      elsif @server.status == 'in_progress'
        if @server.current_turn_server_user == @server_user
          @server.advance_turn
        end
        @server.check_game_end_conditions
      end

      broadcast_game_update
      redirect_to servers_path, notice: 'You have left the game.'
    else
      redirect_to servers_path, alert: 'You are not in this game.'
    end
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
  # In ServerUsersController


  private
  def broadcast_game_update
    @grid_cells = @server.grid_cells.includes(:owner, :treasure)
    @server_users = @server.server_users.includes(:user)
    @server_user = @server.server_users.find_by(user: current_user).includes(:inventories, :treasures)
    @current_turn_user = @server.current_turn_server_user
    @current_turn_user ||= @server.server_users.order(:turn_order).first
    @opponents = @server.server_users.includes(:user, :treasures).where.not(id: @server_user&.id)
    @waiting_for_players = @server.server_users.count < @server.max_players # Calculate the value

    GameChannel.broadcast_to @server, turbo_stream:
      turbo_stream.replace("game-container", partial: "games/game_area", locals: {
        server: @server,
        game: @game,
        server_users: @server_users,
        grid_cells: @grid_cells,
        server_user: @server_user,
        current_turn_user: @current_turn_user,
        opponents: @opponents,
        waiting_for_players: @waiting_for_players # Pass it as a local
      })
  end
  def set_server_user
    @server_user = current_user.server_users.find(params[:id])
  end
  def set_server
    @server = Server.includes(:game).find(params[:server_id])
    @game = @server.game
  end
end
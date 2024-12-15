class ServerUsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_server_user, only: %i[destroy]
  before_action :set_server, only:  %i[create leave]

  # POST /server_users
  def show
    # this code was not meant to be ran
    # :nocov:
    @server = Server.includes(:game).find(params[:server_id])
    @server_users = @server.server_users.includes(:user)
    @waiting_for_players = @server.server_users.count < @server.max_players
    # :nocov:

  end
  def create
    puts @server.users
    if @server.users.include?(current_user)
      redirect_to @server, alert: 'You have already joined this game.'
      return
    end
    puts "CALL2"

    if @server.server_users.count >= @server.max_players
      redirect_to @server, alert: 'Server is full.'
      return
    end
    puts "SUMMON0.1"

    @server_user = @server.server_users.create!(
      user: current_user,
      cable_token: current_user.cable_token,
      total_ap: 200,
      turn_ap: 2,
      shard_balance: 0
    )
    puts "SUMMON"
    #Rails.logger.info "[ServersController#join_game] User #{current_user.username} joined server #{@server.id} with cable_token: #{@server_user.cable_token}"
    @server.assign_symbols_and_turn_order
    @server.assign_starting_positions(new_user: @server_user)

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

  def set_server_user
    @server_user = current_user.server_users.find(params[:id])
    #Rails.logger.info "[ServerUsersController#set_server_user] User ID: #{@server_user.user_id}, Cable Token: #{@server_user.cable_token}"

  end
  def set_server
    @server = Server.includes(:game).find(params[:id])
    #Rails.logger.info "[ServersController#set_server] Loaded server #{@server.id} with users: #{@server.users.pluck(:username).join(', ')}"
  end
  def set_game
    @server = Server.includes(:game).find(params[:id])
    @game = @server.game
    #Rails.logger.info "[ServersController#set_server] Loaded server #{@server.id} with users: #{@server.users.pluck(:username).join(', ')}"
  end
end
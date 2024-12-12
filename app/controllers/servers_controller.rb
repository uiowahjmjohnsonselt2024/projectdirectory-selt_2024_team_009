class ServersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_server, only: [:show, :edit, :update, :destroy, :start_game, :join_game]
  before_action :check_creator, only: %i[start_game]
  # GET /servers
  def index
    Rails.logger.info "[ServersController#index] Current user: #{current_user.username}"
    @servers = Server.all
    @created_servers = current_user.created_servers
    @joined_servers = current_user.servers.where.not(created_by: current_user.id) || []
  end



  # GET /servers/:id
  def show
    @server = Server.includes(:game).find(params[:id])
    Rails.logger.info "[ServersController#show] Server ID: #{@server.id}, Current user: #{current_user.username}"
  end

  # GET /servers/new
  def new
    @server = current_user.created_servers.build
  end

  # POST /servers
  def create
    Rails.logger.info "[ServersController#create] Creating server for user: #{current_user.username}"
    Rails.logger.info "[ServersController#create] Creating server for user token: #{current_user.cable_token}"
    @server = current_user.created_servers.build(server_params) # Automatically associates the server with the logged-in user
    @server.created_by = current_user.id # Explicitly set the created_by field if it's not handled automatically
    Rails.logger.info "[ServersController#create] Server #{@server.creator} created"
    if @server.save
      Rails.logger.info "[ServersController#create] Server #{@server.id} created successfully by #{current_user.username}"
      redirect_to servers_path, notice: 'Server created successfully.'
    else
      Rails.logger.error "DEBUG: Server validation errors: #{@server.errors.full_messages}"
      @server.server_users.each do |su|
        Rails.logger.error "DEBUG: ServerUser validation errors: #{su.errors.full_messages}" unless su.valid?
      end
      render :new, status: :unprocessable_entity
    end
  end



  # GET /servers/:id/edit
  def edit
    # @server is set by before_action
  end

  # PATCH/PUT /servers/:id
  def update
    if @server.update(server_params)
      redirect_to @server, notice: 'Server was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /servers/:id
  def destroy
    if @server.creator == current_user
      @server.destroy
      redirect_to servers_url, notice: 'Server was successfully destroyed.'
    else
      redirect_to servers_url, alert: 'You are not authorized to delete this server.'
    end
  end

  def start_game
    Rails.logger.info "[ServersController#start_game] Attempting to start game on server #{@server.id} by #{current_user.username}"

    if @server.status != 'pending'
      Rails.logger.warn "[ServersController#start_game] Game already started or finished on server #{@server.id}"
      redirect_to @server, alert: 'Game has already started or finished.'
      return
    end

    if @server.server_users.count < 2 && @server.creator != current_user
      Rails.logger.warn "[ServersController#start_game] Not enough players to start game on server #{@server.id}"
      redirect_to @server, alert: 'At least 2 players are required to start the game.'
      return
    end

    insufficient_shards_users = @server.users.select { |user| user.wallet&.balance.to_i < 200 }
    if insufficient_shards_users.any?
      redirect_to new_transaction_path, alert: "Not all players have 200 shards. Please purchase more shards."
      return
    end

    @server.server_users.each do |server_user|
      wallet = server_user.user.wallet
      wallet.update!(balance: wallet.balance - 200)
    end

    if @server.start_game
      @game = @server.game

      GameChannel.broadcast_to(@server, { type: "game_started" })

      respond_to do |format|
        format.html { redirect_to server_game_path(@server, @game), notice: "Game started!" }
        format.turbo_stream {
          @grid_cells = @server.grid_cells.includes(:owner, :treasure) || []
          @server_users = @server.server_users.includes(:user) || []
          @server_user = @server.server_users.includes(:inventories, :treasures).find_by(user: current_user) || nil
          @current_turn_user = @server.current_turn_server_user
          @current_turn_user ||= @server.server_users.order(:turn_order).first
          @opponents = @server.server_users.includes(:user, :treasures) || []
          @waiting_for_players = @server.server_users.count < @server.max_players

          render turbo_stream:
                   turbo_stream.replace("game-container", partial: "games/game_area", locals: {
                     server: @server,
                     game: @game,
                     server_users: @server_users,
                     grid_cells: @grid_cells,
                     server_user: @server_user,
                     current_turn_user: @current_turn_user,
                     opponents: @opponents,
                     waiting_for_players: @waiting_for_players
                   })
        }
      end
    else
      Rails.logger.error "[ServersController#start_game] Game creation failed on server #{@server.id}"
      redirect_to @server, alert: "Failed to start the game. Please try again."
    end
  end

  # POST /servers/:id/join_game
  # POST /servers/:id/join_game
  # POST /servers/:id/join_game
  def join_game
    Rails.logger.info "[ServersController#join_game] User #{current_user.username} attempting to join server #{@server.id}"
    # Log the usernames of all current users in the server
    current_usernames = @server.users.pluck(:username)
    Rails.logger.info "Users currently in servercontroller join_game #{@server.id}: #{current_usernames.join(', ')}"

    if @server.users.include?(current_user)
      Rails.logger.warn "[ServersController#join_game] User #{current_user.username} already joined server #{@server.id}"
      redirect_to server_game_path(@server, @server.game), alert: 'You have already joined this game.'
      return
    end
    Rails.logger.info "[ServersController#join_game] Current user's cable_token: #{current_user.cable_token}"

    if @server.server_users.count >= @server.max_players
      Rails.logger.warn "[ServersController#join_game] Server #{@server.id} is full"
      redirect_to @server, alert: 'Server is full.'
      return
    end

    # Add the current user to the server
    @server_user = @server.server_users.create(user: current_user, cable_token: current_user.cable_token)
    Rails.logger.info "[ServersController#join_game] User #{current_user.username} joined server #{@server.id} with cable_token: #{@server_user.cable_token}"

    # Assign symbol and turn order
    @server.assign_symbols_and_turn_order
    @server.assign_starting_positions(new_user: @server_user)
    # Assign starting position ONLY for the new user
    broadcast_game_update

  end



  private
  def broadcast_game_update
    @grid_cells = @server.grid_cells.includes(:owner, :treasure) || []
    @server_users = @server.server_users.includes(:user) || []
    @server_user = @server.server_users.includes(:inventories, :treasures).find_by(user: current_user) || nil
    @current_turn_user = @server.current_turn_server_user
    @current_turn_user ||= @server.server_users.order(:turn_order).first
    @opponents = @server.server_users.includes(:user, :treasures) || []
    @waiting_for_players = @server.server_users.count < @server.max_players

    GameChannel.broadcast_to @server, turbo_stream:
      turbo_stream.replace("game-container", partial: "games/game_area", locals: {
        server: @server,
        game: @game,
        server_users: @server_users,
        grid_cells: @grid_cells,
        server_user: @server_user,
        current_turn_user: @current_turn_user,
        opponents: @opponents,
        waiting_for_players: @waiting_for_players
      })
  end
  # Set the @server based on the ID in params
  def set_server
    @server = Server.includes(:game).find(params[:id])
    @game = @server.game
    Rails.logger.info "[ServersController#set_server] Loaded server #{@server.id} with users: #{@server.users.pluck(:username).join(', ')}"
  end

  def check_creator
    unless @server.creator == current_user
      Rails.logger.warn "[ServersController#check_creator] User #{current_user.username} is not the creator of server #{@server.id}"
      redirect_to @server, alert: 'Only the creator can start the game.'
    end
  end

  # Strong parameters to prevent mass assignment
  def server_params
    params.require(:server).permit(:name, :max_players)
  end
end
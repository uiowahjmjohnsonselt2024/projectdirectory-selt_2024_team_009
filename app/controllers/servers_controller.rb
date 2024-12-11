class ServersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_server, only: [:show, :edit, :update, :destroy, :start_game, :join_game]
  before_action :check_creator, only: %i[start_game]
  # GET /servers
  def index
    Rails.logger.info "[ServersController#index] Current user: #{current_user.username}"
    @servers = Server.all
    @created_servers = current_user.created_servers
    @joined_servers = current_user.servers.includes(:server_users) || []
  end



  # GET /servers/:id
  def show
    Rails.logger.info "[ServersController#show] Server ID: #{@server.id}, Current user: #{current_user.username}"
  end

  # GET /servers/new
  def new
    @server = current_user.created_servers.build
  end

  # POST /servers
  def create
    Rails.logger.info "[ServersController#create] Creating server for user: #{current_user.username}"
    @server = current_user.created_servers.build(server_params) # Automatically associates the server with the logged-in user
    @server.created_by = current_user.id # Explicitly set the created_by field if it's not handled automatically

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
  # POST /servers/:id/start_game
  # def start_game
  #   if @server.status != 'pending'
  #     redirect_to @server, alert: 'Game has already started or finished.'
  #     return
  #   end
  #
  #   if @server.server_users.count < 2 && @server.creator != current_user
  #     redirect_to @server, alert: 'At least 2 players are required to start the game.'
  #     return
  #   end
  #   # Deduct 200 shards from each player
  #   insufficient_shards_users = @server.users.select { |user| user.wallet&.balance.to_i < 200 }
  #   if insufficient_shards_users.any?
  #     redirect_to new_transaction_path, alert: "Not all players have 200 shards. Please purchase more shards."
  #   else
  #   @server.server_users.each do |server_user|
  #
  #     wallet = server_user.user.wallet
  #
  #     wallet.update!(balance: wallet.balance - 200)
  #   end
  #   @server.start_game
  #   GameChannel.broadcast_to(@server, { type: "page_reload", reason: "Game started" })
  #   redirect_to game_path(@server), notice: 'Game started successfully.'
  #   end
  # end

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

    @server.server_users.each do |server_user|
      # Rails.logger.info "DEBUG: ServerUser token before deduction: #{server_user.cable_token}, User ID: #{server_user.user.id}" # Debug token
      wallet = server_user.user.wallet
      if wallet.balance < 200
        Rails.logger.error "[ServersController#start_game] Insufficient balance for user #{server_user.user.username} (User ID: #{server_user.user.id})"
        Rails.logger.error "ERROR: Insufficient balance for User ID: #{server_user.user.id}" # Log balance issue
        redirect_to new_transaction_path, alert: "Not all players have 200 shards. Please purchase more shards."
        return
      end
      wallet.update!(balance: wallet.balance - 200)
    end

    @server.start_game
    #
    # @server.server_users.each do |su|
    #   puts "ServerUser ID: #{su.id}, Cable Token: #{su.cable_token}, Valid: #{su.valid?}, Errors: #{su.errors.full_messages.join(', ')}"
    # end
    Rails.logger.info "[ServersController#start_game] Game started successfully on server #{@server.id}"
    GameChannel.broadcast_to(@server, { type: "page_reload", reason: "Game started" })
    redirect_to game_path(@server), notice: 'Game started successfully.'
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
      redirect_to game_path(@server), alert: 'You have already joined this game.'
      return
    end
    Rails.logger.info "[ServersController#join_game] Current user's cable_token: #{current_user.cable_token}"

    if @server.server_users.count >= @server.max_players
      Rails.logger.warn "[ServersController#join_game] Server #{@server.id} is full"
      redirect_to @server, alert: 'Server is full.'
      return
    end

    # Add the current user to the server
    @server_user = @server.server_users.create(
      user: current_user,
      cable_token: current_user.cable_token
    )

    Rails.logger.info "[ServersController#join_game] User #{current_user.username} joined server #{@server.id}"

    # Assign symbol and turn order
    @server.assign_symbols_and_turn_order
    @server.assign_starting_positions(new_user: @server_user)
    # Assign starting position ONLY for the new user
    GameChannel.broadcast_to(@server, { type: "page_reload", reason: "Player joined" })
    redirect_to game_path(@server), notice: 'You have joined the game.'

  end



  private
  # Set the @server based on the ID in params
  def set_server
    @server = Server.find(params[:id])
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
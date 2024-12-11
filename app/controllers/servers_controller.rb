class ServersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_server, only: [:show, :edit, :update, :destroy, :start_game, :join_game]
  before_action :check_creator, only: %i[start_game]

  # GET /servers
  def index
    @servers = Server.all
    @joined_servers = current_user.servers.where.not(created_by: current_user.id)
  end


  # GET /servers/:id
  def show
    # @server is set by before_action
  end

  # GET /servers/new
  def new
    @server = current_user.created_servers.build
  end

  # POST /servers
  def create
    @server = current_user.created_servers.build(server_params)
    if @server.save
      server_user = @server.server_users.create(user: current_user)
      # Rails.logger.info "DEBUG: ServerUser created with cable_token: #{server_user.cable_token}" # Debug token
      redirect_to servers_path, notice: 'Server created successfully.'
    else
      Rails.logger.error "DEBUG: Server creation failed with errors: #{@server.errors.full_messages}" # Log errors
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
    if @server.status != 'pending'
      redirect_to @server, alert: 'Game has already started or finished.'
      return
    end

    if @server.server_users.count < 2 && @server.creator != current_user
      redirect_to @server, alert: 'At least 2 players are required to start the game.'
      return
    end

    @server.server_users.each do |server_user|
      # Rails.logger.info "DEBUG: ServerUser token before deduction: #{server_user.cable_token}, User ID: #{server_user.user.id}" # Debug token
      wallet = server_user.user.wallet
      if wallet.balance < 200
        Rails.logger.error "ERROR: Insufficient balance for User ID: #{server_user.user.id}" # Log balance issue
        redirect_to new_transaction_path, alert: "Not all players have 200 shards. Please purchase more shards."
        return
      end
      wallet.update!(balance: wallet.balance - 200)
    end

    @server.start_game
    GameChannel.broadcast_to(@server, { type: "page_reload", reason: "Game started" })
    redirect_to game_path(@server), notice: 'Game started successfully.'
  end

  # POST /servers/:id/join_game
  # POST /servers/:id/join_game
  # POST /servers/:id/join_game
  def join_game
    # Log the usernames of all current users in the server
    current_usernames = @server.users.pluck(:username)
    Rails.logger.info "Users currently in servercontroller join_game #{@server.id}: #{current_usernames.join(', ')}"

    if @server.users.include?(current_user)
      redirect_to game_path(@server), alert: 'You have already joined this game.'
      return
    end

    if @server.server_users.count >= @server.max_players
      redirect_to @server, alert: 'Server is full.'
      return
    end

    # Add the current user to the server
    @server_user = @server.server_users.create(user: current_user)
    # Rails.logger.info "DEBUG: ServerUser joined with cable_token: #{@server_user.cable_token}, User ID: #{@server_user.user.id}" # Log token

    # Assign symbol and turn order
    @server.assign_symbols_and_turn_order

    # Assign starting position ONLY for the new user
    begin
      @server.assign_starting_positions(new_user: @server_user)
    rescue StandardError => e
      Rails.logger.error "Error assigning position: #{e.message}"
      redirect_to @server, alert: 'Failed to assign a starting position.'
      return
    end

    # Broadcast to other players
    GameChannel.broadcast_to(@server, { type: "page_reload", reason: "Player joined" })

    redirect_to game_path(@server), notice: 'You have joined the game.'
  end




  # Set the @server based on the ID in params
  def set_server
    @server = Server.find(params[:id])
    @server.server_users.each do |server_user|
      # Rails.logger.info "DEBUG: ServerUser in server #{@server.id}: ID #{server_user.id}, cable_token: #{server_user.cable_token}" # Debug token
    end
  end

  def check_creator
    unless @server.creator == current_user
      redirect_to @server, alert: 'Only the creator can start the game.'
    end
  end

  # Strong parameters to prevent mass assignment
  def server_params
    params.require(:server).permit(:name, :max_players)
  end
end
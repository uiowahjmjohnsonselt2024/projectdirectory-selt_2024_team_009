class ServersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_server, only: %i[show edit update destroy]

  # GET /servers
  def index
    @servers = Server.all
  end

  # GET /servers/:id
  def show
    # @server is set by before_action
  end

  # GET /servers/new
  def new
    @server = current_user.servers.build
  end

  # POST /servers
  def create
    @server = current_user.servers.build(server_params)
    if @server.save
      redirect_to @server, notice: 'Server was successfully created.'
    else
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
    @server.destroy
    redirect_to servers_url, notice: 'Server was successfully destroyed.'
  end

  private

  # Set the @server based on the ID in params
  def set_server
    @server = Server.find(params[:id])
  end

  # Strong parameters to prevent mass assignment
  def server_params
    params.require(:server).permit(:name, :max_players)
  end
end

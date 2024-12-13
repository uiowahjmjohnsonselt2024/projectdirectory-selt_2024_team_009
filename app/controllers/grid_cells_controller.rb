class GridCellsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_grid_cell, only: %i[show edit update destroy]
  before_action :set_server, only: %i[index]

  # GET /grid_cells
  def index
    @grid_cells = GridCell.all.includes(:server, :content, :treasure)

    # Ensure the shared background image is generated for the server
    if @server.background_image_url.blank?

      image_url = @server.generate_game_board_image

      if image_url
        ##Rails.logger.info "Generated and saved background image for server #{@server.id}: #{image_url}"
      else
        ##Rails.logger.error "Failed to generate background image for server #{@server.id}"
      end
    end
  end

  # GET /grid_cells/:id
  def show
  end

  # GET /grid_cells/new
  def new
    @grid_cell = GridCell.new
  end

  # POST /grid_cells
  def create
    @grid_cell = GridCell.new(grid_cell_params)
    if @grid_cell.save
      redirect_to grid_cells_url(server_id: @grid_cell.server_id), notice: 'Grid cell was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /grid_cells/:id/edit
  def edit
  end

  # PATCH/PUT /grid_cells/:id
  def update
    if @grid_cell.update(grid_cell_params)
      redirect_to grid_cells_url(server_id: @grid_cell.server_id), notice: 'Grid cell was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /grid_cells/:id
  def destroy
    @grid_cell.destroy
    redirect_to grid_cells_url(server_id: @grid_cell.server_id), notice: 'Grid cell was successfully destroyed.'
  end

  private

  def set_server
    # Each grid cell belongs to a server
    @server = Server.includes(:game).find(params[:server_id])
    @game = @server.game
  end

  def set_grid_cell
    @grid_cell = GridCell.find(params[:id])
  end

  def grid_cell_params
    params.require(:grid_cell).permit(:server_id, :x, :y, :content_id, :treasure_id)
  end
end

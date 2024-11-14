class GridCellsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_grid_cell, only: %i[show edit update destroy]

  # GET /grid_cells
  def index
    @grid_cells = GridCell.all.includes(:server, :content, :treasure)
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
      redirect_to @grid_cell, notice: 'Grid cell was successfully created.'
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
      redirect_to @grid_cell, notice: 'Grid cell was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /grid_cells/:id
  def destroy
    @grid_cell.destroy
    redirect_to grid_cells_url, notice: 'Grid cell was successfully destroyed.'
  end

  private

  def set_grid_cell
    @grid_cell = GridCell.find(params[:id])
  end

  def grid_cell_params
    params.require(:grid_cell).permit(:server_id, :x, :y, :content_id, :treasure_id)
  end
end

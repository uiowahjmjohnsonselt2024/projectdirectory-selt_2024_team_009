class TreasuresController < ApplicationController
  before_action :authenticate_user!
  before_action :set_treasure, only: %i[show edit update destroy]

  # GET /treasures
  def index
    @treasures = Treasure.all
  end

  # GET /treasures/:id
  def show
  end

  # GET /treasures/new
  def new
    @treasure = Treasure.new
  end

  # POST /treasures
  def create
    @treasure = Treasure.new(treasure_params)
    if @treasure.save
      redirect_to @treasure, notice: 'Treasure was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /treasures/:id/edit
  def edit
  end

  # PATCH/PUT /treasures/:id
  def update
    if @treasure.update(treasure_params)
      redirect_to @treasure, notice: 'Treasure was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /treasures/:id
  def destroy
    @treasure.destroy
    redirect_to treasures_url, notice: 'Treasure was successfully destroyed.'
  end

  private

  def set_treasure
    @treasure = Treasure.find(params[:id])
  end

  def treasure_params
    params.require(:treasure).permit(:name, :description, :points, :item_id, :unlock_criteria)
  end
end

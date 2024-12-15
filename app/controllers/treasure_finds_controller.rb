class TreasureFindsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_treasure_find, only: %i[show edit update destroy]

  # GET /treasure_finds
  def index
    @treasure_finds = current_user.treasure_finds.includes(:treasure, :server)
  end

  # GET /treasure_finds/:id
  def show
  end

  # GET /treasure_finds/new
  def new
    @treasure_find = current_user.treasure_finds.build
  end

  # POST /treasure_finds
  def create
    @treasure_find = current_user.treasure_finds.build(treasure_find_params)
    @treasure_find.found_at = Time.current
    if @treasure_find.save
      redirect_to @treasure_find, notice: 'Treasure find was successfully recorded.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /treasure_finds/:id/edit
  def edit
  end

  # PATCH/PUT /treasure_finds/:id
  def update
    if @treasure_find.update(treasure_find_params)
      redirect_to @treasure_find, notice: 'Treasure find was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /treasure_finds/:id
  def destroy
    @treasure_find.destroy
    redirect_to treasure_finds_url, notice: 'Treasure find was successfully destroyed.'
  end

  private

  def set_treasure_find
    @treasure_find = current_user.treasure_finds.find(params[:id])
  end

  def treasure_find_params
    params.require(:treasure_find).permit(:treasure_id, :server_id)
  end
end

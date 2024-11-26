class InventoriesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_inventory, only: %i[show edit update destroy]

  # GET /inventories
  def index
    @inventories = current_user.inventories.includes(:item)
  end

  # GET /inventories/:id
  def show
    @inventory = current_user.inventory
  end

  # GET /inventories/new
  def new
    @inventory = current_user.inventories.build
  end

  # POST /inventories
  def create
    @inventory = current_user.inventories.build(inventory_params)
    if @inventory.save
      redirect_to @inventory, notice: 'Inventory item was successfully added.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /inventories/:id/edit
  def edit
    @item = Item.find(params[:item_id])
  end

  # PATCH/PUT /inventories/:id
  def update
    if @inventory.update(inventory_params)
      redirect_to @inventory, notice: 'Inventory item was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /inventories/:id
  def destroy
    @inventory.destroy
    redirect_to inventories_url, notice: 'Inventory item was successfully removed.'
  end

  private

  def set_inventory
    @inventory = current_user.inventories.find(params[:id])
  end

  def inventory_params
    params.require(:inventory).permit(:item_id, :quantity)
  end
end

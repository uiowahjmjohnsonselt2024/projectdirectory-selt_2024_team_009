class InventoriesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_inventory, only: %i[show edit update destroy]

  # GET /inventories
  def index
    @inventories = current_user.inventories.includes(:item)
    render :index
  end

  # GET /inventories/:id
  def show
    @item = Item.find(params[:id])
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
    @inventory = current_user.inventories.find(params[:id])
    @inventory.destroy
    redirect_to inventories_path, notice: 'Item successfully discarded.'
  end

  private

  def add_item

  end
  def set_inventory
    @inventory = current_user.inventories.find(params[:id])
  end

  def inventory_params
    #params.require(:inventory).permit(:item_id, :quantity)
    params.require(:inventory).permit(:item_name, :quantity)
  end
end

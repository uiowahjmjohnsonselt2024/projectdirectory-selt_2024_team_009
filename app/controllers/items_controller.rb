class ItemsController < ApplicationController
  before_action :set_item, only: %i[show edit update destroy purchase]
  before_action :authenticate_user!
  before_action :check_admin, only: %i[new create edit update destroy]

  # GET /items
  def index
    @items = Item.all
  end

  # GET /items/:id
  def show
    # @item is set by before_action
  end

  # GET /items/new (Admin Only)
  def new
    @item = Item.new
  end

  # POST /items (Admin Only)
  def create
    @item = Item.new(item_params)
    if @item.save
      redirect_to items_path, notice: 'Item was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /items/:id/edit (Admin Only)
  def edit
    # @item is set by before_action
  end

  # PATCH/PUT /items/:id (Admin Only)
  def update
    if @item.update(item_params)
      redirect_to items_path, notice: 'Item was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /items/:id (Admin Only)
  def destroy
    @item.destroy
    redirect_to items_url, notice: 'Item was successfully destroyed.'
  end

  # POST /items/:id/purchase (Player Only)
  def purchase
    if current_user.wallet.balance >= @item.price
      # Deduct price from wallet
      current_user.wallet.update(balance: current_user.wallet.balance - @item.price)

      # Add the item to user's inventory
      Inventory.create(user: current_user, item: @item)

      redirect_to items_path, notice: 'Item purchased successfully!'
    else
      redirect_to items_path, alert: 'Insufficient Shards to buy this item.'
    end
  end

  private

  # Set the @item based on the ID in params
  def set_item
    @item = Item.find(params[:id])
  end

  # Strong parameters to prevent mass assignment
  def item_params
    params.require(:item).permit(:name, :description, :price, :category, :required_level, :image_url)
  end

  # Restrict actions to admins
  def check_admin
    redirect_to items_path, alert: 'Access denied.' unless current_user.admin?
  end
end

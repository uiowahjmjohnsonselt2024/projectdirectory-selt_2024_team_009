class ItemsController < ApplicationController
  before_action :set_item, only: %i[show edit update destroy]

  # GET /items
  def index
    @items = Item.all
  end

  # GET /items/:id
  def show
    # @item is set by before_action
  end

  # GET /items/new
  def new
    @item = Item.new
  end

  # POST /items
  def create
    @item = Item.new(item_params)
    if @item.save
      redirect_to @item, notice: 'Item was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /items/:id/edit
  def edit
    # @item is set by before_action
  end

  # PATCH/PUT /items/:id
  def update
    if @item.update(item_params)
      redirect_to @item, notice: 'Item was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /items/:id
  def destroy
    @item.destroy
    redirect_to items_url, notice: 'Item was successfully destroyed.'
  end

  private

  # Set the @item based on the ID in params
  def set_item
    @item = Item.find(params[:id])
  end

  # Strong parameters to prevent mass assignment
  def item_params
    params.require(:item).permit(:name, :description, :price, :category, :required_level)
  end
end

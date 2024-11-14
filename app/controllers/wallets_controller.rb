class WalletsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_wallet, only: %i[show edit update destroy]

  # GET /wallets
  def index
    @wallets = Wallet.where(user: current_user)
  end

  # GET /wallets/:id
  def show
  end

  # GET /wallets/new
  def new
    @wallet = current_user.build_wallet
  end

  # POST /wallets
  def create
    @wallet = current_user.build_wallet(wallet_params)
    if @wallet.save
      redirect_to @wallet, notice: 'Wallet was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /wallets/:id/edit
  def edit
  end

  # PATCH/PUT /wallets/:id
  def update
    if @wallet.update(wallet_params)
      redirect_to @wallet, notice: 'Wallet was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /wallets/:id
  def destroy
    @wallet.destroy
    redirect_to wallets_url, notice: 'Wallet was successfully destroyed.'
  end

  private

  def set_wallet
    @wallet = current_user.wallet
  end

  def wallet_params
    params.require(:wallet).permit(:balance)
  end
end

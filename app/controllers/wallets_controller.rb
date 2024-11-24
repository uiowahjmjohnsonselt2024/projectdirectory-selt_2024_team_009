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
    if current_user.wallet.present?
      redirect_to current_user.wallet, alert: 'Wallet already created'
    else
      @wallet = current_user.build_wallet
    end
  end

  # POST /wallets
  def create
    if current_user.wallet.present?
      redirect_to current_user.wallet, alert: 'You already have a wallet!'
    else
      @wallet = current_user.build_wallet(wallet_params)
      if @wallet.save
        redirect_to @wallet, notice: 'Wallet was successfully created.'
      else
        render :new, status: :unprocessable_entity
      end
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

  def add_shards
    shardAmount = params[:amount].to_i
    if(amount.positive?)
      @wallet.balance += shardAmount
      if @wallet.save
        redirect to @wallet, notice: "#{amount} Shards successfully added"
      else
        redirect_to @wallet, alert: "Operation Failed"
      end
    end

  end

  def subtract_shards
    amount = params[:amount].to_i
    if(amount.positive? && @wallet.balance >= amount)
      @wallet.balance -= amount
      if @wallet.save
        redirect_to @wallet, notice: "#{amount} Shards removed from account"
      else
        redirect_to @wallet, alert: "Operation Failed"
      end
    else
      redirect_to @wallet, alert: "Insufficient Funds"
    end
  end
end

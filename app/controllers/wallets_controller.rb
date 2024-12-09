class WalletsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_wallet, only: %i[show edit update destroy add_shards subtract_shards buy_shards purchase_shards]

  # GET /wallets
  def index
    @wallet = current_user.wallet
  end

  # GET /wallets/:id
  def show
  end
  # GET /wallets/:id/buy_shards
  def buy_shards
    # Displays the shard purchase form
  end

  def purchase_shards
    amount = params[:amount].to_i

    if amount.positive?
      # Simulate payment processing
      sleep(3) # Fake delay of 3 seconds to simulate processing
      @wallet.balance += amount
      
      trans = current_user.transactions.build()
      trans.amount = amount
      trans.description = "Shards"
      trans.quantity = amount
      trans.transaction_type = "purchase"
      trans.currency = params[:currency]
      trans.payment_method = "Credit Card: " + params[:credit_card_number][-4..-1]

      trans.save!()
      
      if @wallet.save
        redirect_to @wallet, notice: "#{amount} Shards successfully purchased!"
      else
        redirect_to buy_shards_wallet_path(@wallet), alert: "Failed to update wallet."
      end
    else
      redirect_to buy_shards_wallet_path(@wallet), alert: "Invalid amount. Please enter a positive number."
    end
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

  # POST /wallets/:id/add_shards
  def add_shards
    shard_amount = params[:amount].to_i
    if shard_amount.positive?
      @wallet.balance += shard_amount
      if @wallet.save
        redirect_to @wallet, notice: "#{shard_amount} Shards successfully added"
      else
        redirect_to @wallet, alert: "Operation Failed"
      end
    else
      redirect_to @wallet, alert: "Invalid amount"
    end
  end

  # POST /wallets/:id/subtract_shards
  def subtract_shards
    amount = params[:amount].to_i
    if amount.positive? && @wallet.balance >= amount
      @wallet.balance -= amount
      if @wallet.save
        redirect_to @wallet, notice: "#{amount} Shards removed from account"
      else
        redirect_to @wallet, alert: "Operation Failed"
      end
    else
      redirect_to @wallet, alert: "Insufficient Funds or Invalid Amount"
    end
  end

  private

  def set_wallet
    @wallet = current_user.wallet
  end

  def wallet_params
    params.require(:wallet).permit(:balance)
  end
end

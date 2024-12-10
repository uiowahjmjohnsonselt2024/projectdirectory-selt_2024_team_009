class WalletsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_wallet, only: %i[show edit destroy subtract_shards purchase_shards]

  # GET /wallets
  def index
    @wallet = current_user.wallet
    puts @wallet.user_id
  end

  # GET /wallets/:id
  def show
  end

  # GET /wallets/:id/purchase_shards
  def purchase_shards
    amount = params[:amount].to_i

    if amount.positive?
      # Simulate payment processing
      sleep(3) # Fake delay of 3 seconds to simulate processing
      @wallet.balance += amount

      # validation on credit cards
      if params[:credit_card_number].gsub(/\s+/, '').match?(/\A\d{16}\z/)

        redirect_to buy_shards_wallet_path(@wallet), alert: "Invalid card info: Card number must be 16 digits long."

      elsif params[:cvv].size != 3

        redirect_to buy_shards_wallet_path(@wallet), alert: "Invalid card info: CVV must be 3 digits long."

      elsif params[:expiry_date].match?(/^(0[1-9]|1[0-2])\/(0[0-9]|1[0-9]|2[0-3])$/)

        redirect_to buy_shards_wallet_path(@wallet), alert: "Invalid card info: Expiry date is in wrong format"

      else
        # update transactions (linkage)
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

  # DELETE /wallets/:id
  def destroy
    @wallet.destroy
    redirect_to wallets_url, notice: 'Wallet was successfully destroyed.'
  end

  # POST /wallets/:id/subtract_shards
  def subtract_shards
    puts "Uncanny run"
    puts params.inspect

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

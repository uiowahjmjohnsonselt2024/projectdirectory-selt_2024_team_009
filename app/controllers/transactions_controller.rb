class TransactionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_transaction, only: %i[show edit update destroy]

  # GET /transactions
  def index
    @transactions = current_user.transactions
  end

  # GET /transactions/:id
  def show
    # @transaction is set by before_action
  end

  # GET /transactions/new
  def new
    @transaction = current_user.transactions.build
  end

  # POST /transactions
  def create
    @transaction = current_user.transactions.build(transaction_params)
    if @transaction.save
      redirect_to @transaction, notice: 'Transaction was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /transactions/:id/edit
  def edit
    # @transaction is set by before_action
  end

  # PATCH/PUT /transactions/:id
  def update
    if @transaction.update(transaction_params)
      redirect_to @transaction, notice: 'Transaction was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /transactions/:id
  def destroy
    @transaction.destroy
    redirect_to transactions_url, notice: 'Transaction was successfully destroyed.'
  end

  private

  # Set the @transaction based on the ID in params
  def set_transaction
    @transaction = current_user.transactions.find(params[:id])
  end

  # Strong parameters to prevent mass assignment
  def transaction_params
    params.require(:transaction).permit(:transaction_type, :amount, :currency, :payment_method, :item_id, :quantity, :description)
  end
end

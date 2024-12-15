require 'rails_helper'
RSpec.describe WalletsController, type: :controller do
  let!(:user) { FactoryBot.create(:user) }
  #let!(:wallet) { FactoryBot.create(:wallet, user: user, balance: 100) }

  before do
    sign_in user
  end

  describe 'GET #index' do
    it 'assigns the current user wallet to @wallet' do
      get :index
      expect(assigns(:wallet)).to eq(user.wallet)
    end
  end

  describe 'GET #show' do
    it 'renders the show template' do
      get :show, params: { id: user.wallet.id }
      expect(response).to render_template(:show)
    end
  end

  describe 'GET #buy_shards' do
    it 'renders the buy_shards template' do
      get :buy_shards, params: { id: user.wallet.id }
      expect(response).to render_template(:buy_shards)
    end
  end

  describe 'POST #purchase_shards' do
    context 'with valid card details' do
      let(:valid_params) do
        {
          id: user.wallet.id,
          amount: 50,
          credit_card_number: '1234123412341234',
          cvv: '123',
          expiry_date: '12/27',
          currency: 'USD'
        }
      end

      it 'adds shards to the wallet' do
        post :purchase_shards, params: valid_params
        user.wallet.reload
        expect(user.wallet.balance).to eq(550)
        expect(response).to redirect_to(wallet_path(user.wallet))
        expect(flash[:notice]).to eq('50 Shards successfully purchased!')
      end
    end

    context 'with invalid card details' do
      it 'rejects invalid card number' do
        post :purchase_shards, params: { id: user.wallet.id, amount: 50, credit_card_number: '1234', cvv: '123', expiry_date: '12/29' }
        expect(flash[:alert]).to eq('Invalid card info: Card number must be 16 digits long.')
      end

      it 'rejects invalid CVV' do
        post :purchase_shards, params: { id: user.wallet.id, amount: 50, credit_card_number: '4111111111111111', cvv: '12', expiry_date: '12/29' }
        expect(flash[:alert]).to eq('Invalid card info: CVV must be 3 digits long.')
      end

      it 'rejects invalid expiry date' do
        post :purchase_shards, params: { id: user.wallet.id, amount: 50, credit_card_number: '4111111111111111', cvv: '123', expiry_date: '13/29' }
        expect(flash[:alert]).to eq('Invalid card info: Expiry date is in wrong format')
      end

      it 'rejects invalid amount' do
        post :purchase_shards, params: { id: user.wallet.id, amount: -10, credit_card_number: '4111111111111111', cvv: '123', expiry_date: '12/29' }
        expect(flash[:alert]).to eq('Invalid amount. Please enter a positive number.')
      end
    end
  end

  describe 'POST #add_shards' do
    it 'adds shards to the wallet balance' do
      post :add_shards, params: { id: user.wallet.id, amount: 50 }
      user.wallet.reload
      expect(user.wallet.balance).to eq(550)
      expect(response).to redirect_to(wallet_path(user.wallet))
      expect(flash[:notice]).to eq('50 Shards successfully added')
    end

    it 'rejects invalid amount' do
      post :add_shards, params: { id: user.wallet.id, amount: -10 }
      expect(flash[:alert]).to eq('Invalid amount')
    end
  end

  describe 'POST #subtract_shards' do
    it 'subtracts shards from the wallet balance' do
      post :subtract_shards, params: { id: user.wallet.id, amount: 50 }
      user.wallet.reload
      expect(user.wallet.balance).to eq(450)
      expect(response).to redirect_to(wallet_path(user.wallet))
      expect(flash[:notice]).to eq('50 Shards removed from account')
    end

    it 'rejects insufficient funds' do
      post :subtract_shards, params: { id: user.wallet.id, amount: 700 }
      expect(flash[:alert]).to eq('Insufficient Funds or Invalid Amount')
    end

    it 'rejects invalid amount' do
      post :subtract_shards, params: { id: user.wallet.id, amount: -10 }
      expect(flash[:alert]).to eq('Insufficient Funds or Invalid Amount')
    end
  end
end

require 'rails_helper'

RSpec.describe ItemsController, type: :controller do
  let(:user) { create(:user) }
  let(:admin) { create(:user, role: "admin") }
  let(:item) { create(:item) }
  let(:wallet) { create(:wallet, user: user, balance: 100) }

  before do
    # Ensure the user is authenticated
    sign_in user
  end

  describe 'GET #index' do
    it 'returns a success response' do
      get :index
      expect(response).to be_successful
      expect(assigns(:items)).to eq(Item.all)
    end
  end

  describe 'GET #show' do
    it 'returns a success response' do
      get :show, params: { id: item.id }
      expect(response).to be_successful
      expect(assigns(:item)).to eq(item)
    end
  end

  describe 'GET #new' do
    context 'when user is admin' do
      before { sign_in admin }

      it 'returns a success response' do
        get :new
        expect(response).to be_successful
        expect(assigns(:item)).to be_a_new(Item)
      end
    end

    context 'when user is not admin' do
      it 'redirects to items path with access denied alert' do
        get :new
        expect(response).to redirect_to(items_path)
        expect(flash[:alert]).to eq('Access denied.')
      end
    end
  end

  describe 'POST #create' do
    context 'when user is admin' do
      before { sign_in admin }

      context 'with valid params' do
        it 'creates a new item' do
          expect {
            post :create, params: { item: attributes_for(:item) }
          }.to change(Item, :count).by(1)
        end

        it 'redirects to items path with a success message' do
          post :create, params: { item: attributes_for(:item) }
          expect(response).to redirect_to(items_path)
          expect(flash[:notice]).to eq('Item was successfully created.')
        end
      end

      context 'with invalid params' do
        it 'does not create a new item' do
          expect {
            post :create, params: { item: { name: nil } }
          }.to_not change(Item, :count)
        end

        it 'renders the new template with unprocessable entity status' do
          post :create, params: { item: { name: nil } }
          expect(response).to render_template(:new)
          expect(response.status).to eq(422)
        end
      end
    end

    context 'when user is not admin' do
      it 'redirects to items path with access denied alert' do
        post :create, params: { item: attributes_for(:item) }
        expect(response).to redirect_to(items_path)
        expect(flash[:alert]).to eq('Access denied.')
      end
    end
  end

  describe 'GET #edit' do
    context 'when user is admin' do
      before { sign_in admin }

      it 'returns a success response' do
        get :edit, params: { id: item.id }
        expect(response).to be_successful
        expect(assigns(:item)).to eq(item)
      end
    end

    context 'when user is not admin' do
      it 'redirects to items path with access denied alert' do
        get :edit, params: { id: item.id }
        expect(response).to redirect_to(items_path)
        expect(flash[:alert]).to eq('Access denied.')
      end
    end
  end

  describe 'PATCH/PUT #update' do
    context 'when user is admin' do
      before { sign_in admin }

      context 'with valid params' do
        it 'updates the item' do
          put :update, params: { id: item.id, item: { name: 'Updated Item' } }
          item.reload
          expect(item.name).to eq('Updated Item')
        end

        it 'redirects to items path with a success message' do
          put :update, params: { id: item.id, item: { name: 'Updated Item' } }
          expect(response).to redirect_to(items_path)
          expect(flash[:notice]).to eq('Item was successfully updated.')
        end
      end

      context 'with invalid params' do
        it 'does not update the item' do
          put :update, params: { id: item.id, item: { name: nil } }
          item.reload
          expect(item.name).to_not eq(nil)
        end

        it 'renders the edit template with unprocessable entity status' do
          put :update, params: { id: item.id, item: { name: nil } }
          expect(response).to render_template(:edit)
          expect(response.status).to eq(422)
        end
      end
    end

    context 'when user is not admin' do
      it 'redirects to items path with access denied alert' do
        put :update, params: { id: item.id, item: { name: 'Updated Item' } }
        expect(response).to redirect_to(items_path)
        expect(flash[:alert]).to eq('Access denied.')
      end
    end
  end

  describe 'DELETE #destroy' do
    context 'when user is admin' do
      before { sign_in admin }

      it 'destroys the item' do
        item = create(:item)
        expect {
          delete :destroy, params: { id: item.id }
        }.to change(Item, :count).by(-1)
      end

      it 'redirects to items path with a success message' do
        delete :destroy, params: { id: item.id }
        expect(response).to redirect_to(items_url)
        expect(flash[:notice]).to eq('Item was successfully destroyed.')
      end
    end

    context 'when user is not admin' do
      it 'redirects to items path with access denied alert' do
        delete :destroy, params: { id: item.id }
        expect(response).to redirect_to(items_path)
        expect(flash[:alert]).to eq('Access denied.')
      end
    end
  end

  describe 'POST #purchase' do
    context 'when user has sufficient balance' do
      it 'deducts price from wallet and adds item to inventory' do
        expect {
          post :purchase, params: { id: item.id }
        }.to change { user.wallet.reload.balance }.by(-item.price)
        expect(Inventory.where(user: user, item: item).count).to eq(1)
        expect(flash[:notice]).to eq('Item purchased successfully!')
      end
    end
  end
end

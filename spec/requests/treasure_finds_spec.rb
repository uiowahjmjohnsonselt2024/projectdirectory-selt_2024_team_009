require 'rails_helper'

RSpec.describe TreasuresController, type: :controller do
  let(:user) { create(:user) }
  let(:treasure) { create(:treasure, item: create(:item)) }
  let(:valid_attributes) { { name: 'Test Treasure', description: 'A valuable treasure', points: 100, item_id: 1, unlock_criteria: 'Level 1' } }
  let(:invalid_attributes) { { name: "f", description: "few", points: 23, item_id: 12, unlock_criteria: "K" } }

  before do
    sign_in user
  end

  describe 'GET #index' do
    it 'assigns @treasures and renders the index template' do
      treasure
      get :index
      expect(assigns(:treasures)).to eq([treasure])
      expect(response).to render_template(:index)
    end
  end

  describe 'GET #show' do
    it 'assigns the requested treasure to @treasure' do
      get :show, params: { id: treasure.id }
      expect(assigns(:treasure)).to eq(treasure)
      expect(response).to render_template(:show)
    end
  end

  describe 'GET #new' do
    it 'assigns a new treasure to @treasure' do
      get :new
      expect(assigns(:treasure)).to be_a_new(Treasure)
      expect(response).to render_template(:new)
    end
  end

  describe 'POST #create' do
    context 'with valid parameters' do
      it 'creates a new treasure and redirects to the show page' do
        expect {
          post :create, params: { treasure: valid_attributes }
        }.to change(Treasure, :count).by(0)
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new treasure and re-renders the new template' do
        expect {
          post :create, params: { treasure: invalid_attributes }
        }.to_not change(Treasure, :count)
        expect(response).to render_template(:new)
        expect(response.status).to eq(422)
      end
    end
  end

  describe 'GET #edit' do
    it 'assigns the requested treasure to @treasure' do
      get :edit, params: { id: treasure.id }
      expect(assigns(:treasure)).to eq(treasure)
      expect(response).to render_template(:edit)
    end
  end

  describe 'PATCH/PUT #update' do
    context 'with valid parameters' do
      it 'updates the requested treasure and redirects to the show page' do
        put :update, params: { id: treasure.id, treasure: valid_attributes }
        treasure.reload
        expect(treasure.name).to eq('Test Treasure')
        expect(treasure.description).to eq('A valuable treasure')
        expect(treasure.points).to eq(100)
        expect(response).to redirect_to(treasure)
        expect(flash[:notice]).to eq('Treasure was successfully updated.')
      end
    end

    context 'with invalid parameters' do
      it 'does not update the treasure and re-renders the edit template' do
        put :update, params: { id: treasure.id, treasure: invalid_attributes }
        treasure.reload
        expect(treasure.name).not_to eq(nil)
        expect(response).to render_template(:edit)
        expect(response.status).to eq(422)
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested treasure and redirects to treasures_url' do
      treasure
      expect {
        delete :destroy, params: { id: treasure.id }
      }.to change(Treasure, :count).by(-1)
      expect(response).to redirect_to(treasures_url)
      expect(flash[:notice]).to eq('Treasure was successfully destroyed.')
    end
  end
end

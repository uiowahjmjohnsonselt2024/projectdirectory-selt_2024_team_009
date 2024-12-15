require 'rails_helper'

RSpec.describe GridCellsController, type: :controller do
  let!(:user) { create(:user) }
  let!(:server) { create(:server, max_players: 2) }
  let!(:grid_cell) { create(:grid_cell, server: server) }

  before do
    sign_in user
  end

  describe 'GET #index' do
    context 'when background image is not set for the server' do
      it 'generates a background image for the server' do
        allow(server).to receive(:background_image_url).and_return('')
        allow(server).to receive(:generate_game_board_image).and_return('some_image_url')

        get :index, params: { server_id: server.id }

        expect(assigns(:grid_cells)).to be_present
      end
    end

    context 'when background image is already set for the server' do
      it 'does not generate a new background image' do
        allow(server).to receive(:background_image_url).and_return('some_image_url')

        get :index, params: { server_id: server.id }

        expect(assigns(:grid_cells)).to be_present
      end
    end
  end

  describe 'GET #show' do
    it 'assigns the requested grid_cell to @grid_cell' do
      get :show, params: { id: grid_cell.id }

      expect(assigns(:grid_cell)).to eq(grid_cell)
    end
  end

  describe 'GET #new' do
    it 'assigns a new grid_cell to @grid_cell' do
      get :new, params: { server_id: server.id }

      expect(assigns(:grid_cell)).to be_a_new(GridCell)
    end
  end

  describe 'POST #create' do
    context 'with invalid parameters' do
      let(:invalid_params) { { server_id: server.id, x: nil, y: nil } }

      it 'does not create a new grid_cell and re-renders the new template' do
        expect {
          post :create, params: { grid_cell: invalid_params }
        }.to_not change(GridCell, :count)

        expect(response).to render_template(:new)
      end
    end
  end

  describe 'GET #edit' do
    it 'assigns the requested grid_cell to @grid_cell' do
      get :edit, params: { id: grid_cell.id }

      expect(assigns(:grid_cell)).to eq(grid_cell)
    end
  end

  describe 'PATCH #update' do
    context 'with valid parameters' do
      let(:valid_params) { { x: 2, y: 2 } }

      it 'updates the grid_cell and redirects to the grid_cells index' do
        patch :update, params: { id: grid_cell.id, grid_cell: valid_params }

        grid_cell.reload
        expect(grid_cell.x).to eq(2)
        expect(grid_cell.y).to eq(2)
        expect(response).to redirect_to(grid_cells_url(server_id: server.id))
        expect(flash[:notice]).to eq('Grid cell was successfully updated.')
      end
    end

    context 'with invalid parameters' do
      let(:invalid_params) { { x: nil, y: nil } }

      it 'does not update the grid_cell and re-renders the edit template' do
        patch :update, params: { id: grid_cell.id, grid_cell: invalid_params }

        grid_cell.reload
        expect(grid_cell.x).not_to eq(nil)
        expect(response).to render_template(:edit)
      end
    end
  end

  describe 'private methods' do
    describe '#set_server' do
      it 'sets the server based on server_id' do
        get :index, params: { server_id: server.id }

        expect(assigns(:server)).to eq(server)
      end
    end

    describe '#set_grid_cell' do
      it 'sets the grid_cell based on id' do
        get :show, params: { id: grid_cell.id }

        expect(assigns(:grid_cell)).to eq(grid_cell)
      end
    end
  end
end

require 'rails_helper'

RSpec.describe ScoresController, type: :controller do
  let!(:user) { create(:user) }
  let!(:server) { create(:server, created_by: user.id, max_players: 2, status:"pending") }
  let!(:game) { create(:game, server: server) }
  let!(:score) { create(:score, user: user, server: server) }
  let!(:server_user_1) { create(:server_user, server: server, user: user) }
  let!(:server_user_2) { create(:server_user, server: server, user: create(:user)) }

  before do
    sign_in user
  end

  describe 'POST #start' do
    context 'when the server status is not pending' do
      it 'redirects to the server with an alert' do
        post :start, params: { id: server.id }
        expect(response).to redirect_to(server_path(server))
        expect(flash[:alert]).to eq('Game has already started or finished.')
      end
    end

    context 'when there are less than 2 players' do
      it 'redirects to the server with an alert' do
        server.server_users.delete(server_user_2)
        post :start, params: { id: server.id }
        expect(response).to redirect_to(server_path(server))
        expect(flash[:alert]).to eq('At least 2 players are required to start the game.')
      end
    end

    context 'when there are 2 or more players and the server is pending' do
      it 'assigns symbols, turns, positions and initializes the grid' do
        allow(controller).to receive(:assign_symbols_and_turn_order)
        allow(controller).to receive(:assign_starting_positions)
        allow(controller).to receive(:initialize_grid)

        post :start, params: { id: server.id }

        expect(controller).to have_received(:assign_symbols_and_turn_order)
        expect(controller).to have_received(:assign_starting_positions)
        expect(controller).to have_received(:initialize_grid)
        expect(server.reload.status).to eq('in_progress')
        expect(response).to redirect_to(server_game_path(server, server.game))
        expect(flash[:notice]).to eq('Game started successfully.')
      end
    end
  end

  describe 'GET #index' do
    it 'assigns @scores' do
      get :index
      expect(assigns(:scores)).to eq([score])
    end
  end

  describe 'GET #show' do
    it 'assigns @score' do
      get :show, params: { id: score.id }
      expect(assigns(:score)).to eq(score)
    end
  end

  describe 'GET #new' do
    it 'assigns a new score to @score' do
      get :new
      expect(assigns(:score)).to be_a_new(Score)
    end
  end

  describe 'POST #create' do
    context 'with valid parameters' do
      it 'creates a new score and redirects' do
        post :create, params: { score: { server_id: server.id, points: 100, level: 2 } }
        expect(Score.count).to eq(2)
        expect(response).to redirect_to(score_path(assigns(:score)))
        expect(flash[:notice]).to eq('Score was successfully created.')
      end
    end

    context 'with invalid parameters' do
      it 'renders the new template with errors' do
        post :create, params: { score: { points: nil, level: nil } }
        expect(response).to render_template(:new)
        expect(flash[:alert]).to be_nil
      end
    end
  end

  describe 'GET #edit' do
    it 'assigns @score' do
      get :edit, params: { id: score.id }
      expect(assigns(:score)).to eq(score)
    end
  end

  describe 'PATCH/PUT #update' do
    context 'with valid parameters' do
      it 'updates the score and redirects' do
        patch :update, params: { id: score.id, score: { points: 200 } }
        expect(score.reload.points).to eq(200)
        expect(response).to redirect_to(score_path(score))
        expect(flash[:notice]).to eq('Score was successfully updated.')
      end
    end

    context 'with invalid parameters' do
      it 'renders the edit template with errors' do
        patch :update, params: { id: score.id, score: { points: nil } }
        expect(response).to render_template(:edit)
        expect(flash[:alert]).to be_nil
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the score and redirects to scores_url' do
      delete :destroy, params: { id: score.id }
      expect(Score.exists?(score.id)).to be_falsey
      expect(response).to redirect_to(scores_url)
      expect(flash[:notice]).to eq('Score was successfully destroyed.')
    end
  end

  describe 'private methods' do
    describe '#assign_symbols_and_turn_order' do
      it 'assigns symbols and turn order' do
        expect { controller.send(:assign_symbols_and_turn_order) }
          .to change { server.server_users.pluck(:symbol, :turn_order) }
      end
    end

    describe '#assign_starting_positions' do
      it 'assigns starting positions to server users' do
        allow(controller).to receive(:valid_starting_position?).and_return(true)
        expect { controller.send(:assign_starting_positions) }.to change { server.server_users.first.current_position_x }
      end
    end

    describe '#initialize_grid' do
      it 'creates grid cells and assigns treasures and obstacles' do
        expect { controller.send(:initialize_grid) }
          .to change { GridCell.count }.by(36)
      end
    end
  end
end

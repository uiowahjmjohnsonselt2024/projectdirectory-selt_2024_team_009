require 'rails_helper'

RSpec.describe GamesController, type: :controller do
  let!(:user) { create(:user) }
  let!(:server) { create(:server, created_by: user.id, max_players: 2, status:"in_progress", current_turn_server_user: user) }
  let!(:game) { create(:game, server: server) }
  let(:server_user) { create(:server_user, user: user, server: server) }
  before do
    sign_in user
  end

  describe "GET /games/:id" do
    it 'loads the game data and responds successfully' do
      get :show, params: { server_id: server.id, id: game.id }
      expect(response).to have_http_status(:ok)
      expect(assigns(:server)).to eq(server)
      expect(assigns(:game)).to eq(game)
    end
  end

  describe 'POST #perform_action' do
    context 'when the action is valid' do
      it 'performs the move action successfully' do
        post :perform_action, params: {
          server_id: server.id,
          id: game.id,
          action_type: 'move',
          direction: 'up'
        }

        expect(response).to redirect_to(server_game_path(server, game))
        expect(flash[:notice]).to eq('Action completed successfully.')
      end
    end
  end
end
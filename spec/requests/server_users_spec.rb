require 'rails_helper'

RSpec.describe ServerUsersController, type: :controller do
  let!(:user) { create(:user) }
  let!(:user2) { create(:user) }
  let!(:server) { create(:server, max_players: 2) }
  let!(:game) { create(:game, server: server) }

  let!(:server_user) {
     create(:server_user, server: server, user: user) 
    }

  before do
    sign_in user
  end

  describe "POST #create" do
    context "when the user is already in the game" do
      it "redirects with an alert" do
        post :create, params: { server_id: server.id, id: game.id }

        expect(response).to redirect_to(server)
        expect(flash[:alert]).to eq('You have already joined this game.')
      end
    end

    context "when the server is full" do
      it "redirects with an alert" do
        post :create, params: { server_id: server.id, id: game.id }

        expect(response).to redirect_to(server)
        expect(flash[:alert]).to eq('Server is full.')
      end
    end

    context "when the user joins the game" do
      it "creates a server_user and redirects to the game path" do
        post :create, params: { server_id: server.id, id:game.id }

        expect(ServerUser.count).to eq(1)
        expect(response).to redirect_to(server_game_path(server, server.game))
        expect(flash[:notice]).to eq('You have joined the game.')
      end
    end
  end

  describe "POST #leave" do
    before { server_user }

    context "when the user is in the server" do
      it "destroys the server_user and redirects to the servers path" do
        post :leave, params: { server_id: server.id, id: game.id }

        expect(ServerUser.count).to eq(0)
        expect(response).to redirect_to(servers_path)
        expect(flash[:notice]).to eq('You have left the game.')
      end

      context "when the server is in progress" do
        before { server.update(status: 'in_progress') }

        it "advances the turn if the user is the current turn" do
          allow(server).to receive(:current_turn_server_user).and_return(server_user)
          expect(server).to receive(:advance_turn)

          post :leave, params: { server_id: server.id }
        end

        it "checks game end conditions" do
          allow(server).to receive(:current_turn_server_user).and_return(server_user)
          expect(server).to receive(:check_game_end_conditions)

          post :leave, params: { server_id: server.id }
        end
      end

      context "when the server is pending" do
        before { server.update(status: 'pending') }

        it "reassigns symbols and positions" do
          expect(server).to receive(:assign_symbols_and_turn_order)
          expect(server).to receive(:assign_starting_positions)

          post :leave, params: { server_id: server.id }
        end
      end
    end

    context "when the user is not in the server" do
      it "redirects with an alert" do
        server_user.destroy

        post :leave, params: { server_id: server.id }

        expect(response).to redirect_to(servers_path)
        expect(flash[:alert]).to eq('You are not in this game.')
      end
    end
  end

  describe "DELETE #destroy" do
    context "when the user is the server creator" do
      let!(:server_creator) { create(:user) }
      let!(:server) { create(:server, creator: server_creator) }

      before { sign_in server_creator }

      it "destroys the server and redirects" do
        delete :destroy, params: { id: server.id }

        expect(Server.exists?(server.id)).to be false
        expect(response).to redirect_to(servers_url)
        expect(flash[:notice]).to eq('Server was successfully destroyed.')
      end
    end

    context "when the user is not the server creator" do
      it "redirects with an alert" do
        delete :destroy, params: { server_id: server.id, id: server_user.id }

        expect(response).to redirect_to(servers_url)
        expect(flash[:alert]).to eq('You are not authorized to delete this server.')
      end
    end
  end
end

# spec/controllers/servers_controller_spec.rb
require 'rails_helper'

RSpec.describe ServersController, type: :controller do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:server) { create(:server, creator: user, max_players: 2) }
  let(:game) { create(:game, server: server) }

  before do
    sign_in user
  end

  describe 'GET #index' do
    it 'assigns @servers, @created_servers, and @joined_servers' do
      created_server = create(:server, creator: user, max_players:2)
      joined_server = create(:server, creator: other_user, max_players:2)
      user.servers << joined_server

      get :index
      expect(assigns(:servers)).to include(created_server)
      expect(assigns(:created_servers)).to include(created_server)
      expect(assigns(:joined_servers)).to include(joined_server)
    end
  end

  describe 'GET #show' do
    it 'assigns @server and @server_users' do
      server_user = create(:server_user, server: server, user: user)

      get :show, params: { id: server.id }
      expect(assigns(:server)).to eq(server)
      expect(assigns(:server_users)).to include(server_user.as_json(methods: [:cable_token]))
    end
  end

  describe 'GET #new' do
    it 'assigns a new server to @server' do
      get :new
      expect(assigns(:server)).to be_a_new(Server)
    end
  end

  describe 'POST #create' do
    context 'with valid attributes' do
      it 'creates a new server and redirects to servers_path' do
        post :create, params: { server: { name: 'New Server', max_players: 4 } }
        expect(Server.count).to eq(1)
        expect(response).to redirect_to(servers_path)
      end
    end

    context 'with invalid attributes' do
      it 'does not create a new server and re-renders the new template' do
        post :create, params: { server: { name: '', max_players: 0 } }
        expect(Server.count).to eq(0)
        expect(response).to render_template(:new)
      end
    end
  end

  describe 'GET #edit' do
    it 'assigns @server' do
      get :edit, params: { id: server.id }
      expect(assigns(:server)).to eq(server)
    end
  end

  describe 'PATCH #update' do
    context 'with valid attributes' do
      it 'updates the server and redirects to the show page' do
        patch :update, params: { id: server.id, server: { name: 'Updated Server' } }
        server.reload
        expect(server.name).to eq('Updated Server')
        expect(response).to redirect_to(server)
      end
    end

    context 'with invalid attributes' do
      it 'does not update the server and re-renders the edit template' do
        patch :update, params: { id: server.id, server: { name: '', max_players: 0 } }
        expect(response).to render_template(:edit)
      end
    end
  end

  describe 'DELETE #destroy' do
    context 'when the user is the creator' do
      it 'destroys the server and redirects to servers_url' do
        delete :destroy, params: { id: server.id }
        expect(Server.exists?(server.id)).to be_falsey
        expect(response).to redirect_to(servers_url)
      end
    end

    context 'when the user is not the creator' do
      before { sign_in other_user }

      it 'does not destroy the server and redirects with an alert' do
        delete :destroy, params: { id: server.id }
        expect(Server.exists?(server.id)).to be_truthy
        expect(response).to redirect_to(servers_url)
        expect(flash[:alert]).to eq('You are not authorized to delete this server.')
      end
    end
  end

  describe 'POST #start_game' do
    context 'when the game cannot start' do
      it 'redirects with an alert if the server status is not pending' do
        server.update(status: 'in_progress')
        post :start_game, params: { id: server.id }
        expect(response).to redirect_to(server)
        expect(flash[:alert]).to eq('Game has already started or finished.')
      end

      it 'redirects with an alert if there are not enough players' do
        server.update(status: 'pending')
        post :start_game, params: { id: server.id }
        expect(response).to redirect_to(server)
        expect(flash[:alert]).to eq('At least 2 players are required to start the game.')
      end

      it 'redirects with an alert if players have insufficient shards' do
        allow_any_instance_of(Server).to receive(:users).and_return([user])
        user.create_wallet(balance: 100)
        post :start_game, params: { id: server.id }
        expect(response).to redirect_to(new_transaction_path)
        expect(flash[:alert]).to eq('Not all players have 200 shards. Please purchase more shards.')
      end
    end

    context 'when the game starts successfully' do
      it 'starts the game and redirects to the game path' do
        create(:server_user, server: server, user: user)
        post :start_game, params: { id: server.id }
        expect(response).to redirect_to(server_game_path(server, server.game))
        expect(flash[:notice]).to eq('Game started!')
      end
    end
  end

  describe 'POST #join_game' do
    context 'when the user is already in the game' do
      it 'redirects with an alert' do
        create(:server_user, server: server, user: user)
        post :join_game, params: { id: server.id }
        expect(response).to redirect_to(server)
        expect(flash[:alert]).to eq('You have already joined this game.')
      end
    end

    context 'when the server is full' do
      it 'redirects with an alert' do
        server.update(max_players: 1)
        create(:server_user, server: server, user: user)
        post :join_game, params: { id: server.id }
        expect(response).to redirect_to(server)
        expect(flash[:alert]).to eq('Server is full.')
      end
    end

    context 'when the user joins the game successfully' do
      it 'assigns a symbol, turn order, and starting positions' do
        post :join_game, params: { id: server.id }
        expect(response).to redirect_to(server)
        expect(flash[:notice]).to eq('Joined the game!')
      end
    end
  end
end

require 'rails_helper'

RSpec.describe "Games", type: :request do
  let(:user) { create(:user) }
  let(:server) { create(:server, created_by: user.id) }
  let(:game) { create(:game, server: server) }
  let(:server_user) { create(:server_user, user: user, server: server) }

  before do
    sign_in user
    server_user
  end

  describe "GET /games/:id" do
    it "renders the game show page with Turbo Streams" do
      get server_game_path(server, game), headers: { "Accept" => "text/vnd.turbo-stream.html" }
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("turbo-stream")
    end
  end

  describe "PATCH /games/:id/update_game_board" do
    it "updates the game board with Turbo Streams" do
      patch update_game_board_server_game_path(server, game), headers: { "Accept" => "text/vnd.turbo-stream.html" }
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("turbo-stream")
    end
  end
end
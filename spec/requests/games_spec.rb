require 'rails_helper'

RSpec.describe "Games", type: :request do
  describe "GET /show" do
    it "returns http success" do
      get "/games/show"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /play_turn" do
    it "returns http success" do
      get "/games/play_turn"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /perform_action" do
    it "returns http success" do
      get "/games/perform_action"
      expect(response).to have_http_status(:success)
    end
  end

end

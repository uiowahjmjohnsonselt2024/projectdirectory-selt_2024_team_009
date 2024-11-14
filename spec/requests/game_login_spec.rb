require 'rails_helper'

RSpec.describe "GameLogins", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/game_login/index"
      expect(response).to have_http_status(:success)
    end
  end

end

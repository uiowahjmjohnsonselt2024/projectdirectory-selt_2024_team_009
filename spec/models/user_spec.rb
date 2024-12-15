require 'rails_helper'

RSpec.describe User, type: :model do
  let!(:user) { User.create(username: "PlayerOne", email: "player@example.com", password: "password123", score: 100) }

  describe "User attributes" do
    it "should have a username" do
      expect(user.username).to eq("PlayerOne")
    end

    it "should have an email" do
      expect(user.email).to eq("player@example.com")
    end

    it "should have a password" do
      expect(user.password).to eq("password123")
    end

    it "should have a player score" do
      expect(user.score).to eq(100)
    end

    it "should calculate account age correctly" do
      account_age = (Time.now - user.created_at).to_i / (60 * 60 * 24)  # Convert seconds to days
      expect(user.account_age).to eq(account_age)
    end
  end

  describe "Validations" do
    it "should validate presence of username" do
      user.username = nil
      expect(user).not_to be_valid
      expect(user.errors[:username]).to include("can't be blank")
    end

    it "should validate presence of email" do
      user.email = nil
      expect(user).not_to be_valid
      expect(user.errors[:email]).to include("can't be blank")
    end

    it "should validate presence of password" do
      user.password = nil
      expect(user).not_to be_valid
      expect(user.errors[:password]).to include("can't be blank")
    end

    it "should validate presence of score" do
      user.score = nil
      expect(user).not_to be_valid
      expect(user.errors[:score]).to include("can't be blank")
    end
  end
end

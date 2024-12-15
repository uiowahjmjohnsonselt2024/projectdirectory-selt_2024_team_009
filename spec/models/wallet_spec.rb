require 'rails_helper'

RSpec.describe Wallet, type: :model do
  let(:user) { User.create(username: "PlayerOne", email: "playerone@example.com", password: "password") }
  let(:wallet) { Wallet.create(user: user, balance: 0.0) }

  describe "Validations" do
    it "should have a user_id" do
      wallet.user_id = nil
      expect(wallet).not_to be_valid
      expect(wallet.errors[:user_id]).to include("can't be blank")
    end

    it "should ensure the user_id is unique" do
      wallet2 = Wallet.create(user: user, balance: 50.0)
      wallet3 = Wallet.create(user: user, balance: 100.0)

      expect(wallet3.errors[:user_id]).to include("has already been taken")
    end

    it "should have a balance that defaults to 0.0" do
      expect(wallet.balance).to eq(0.0)
    end

    it "should not allow null balance" do
      wallet.balance = nil
      expect(wallet).not_to be_valid
      expect(wallet.errors[:balance]).to include("can't be blank")
    end
  end

  describe "Shards management" do
    it "should allow adding shards to the wallet" do
      wallet.add_shards(50.0)
      expect(wallet.balance).to eq(50.0)
    end

    it "should allow subtracting shards from the wallet" do
      wallet.add_shards(50.0)
      wallet.subtract_shards(20.0)
      expect(wallet.balance).to eq(30.0)
    end

    it "should not allow the balance to go below 0" do
      wallet.subtract_shards(50.0)
      expect(wallet.balance).to eq(0.0)
    end
  end

  describe "Associations" do
    it "should belong to a user" do
      expect(wallet.user).to eq(user)
    end
  end
end

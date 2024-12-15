require 'rails_helper'

RSpec.describe TreasureFind, type: :model do
  let(:user) { User.create(username: "PlayerOne", email: "playerone@example.com", password: "password") }
  let(:treasure) { Treasure.create(name: "Golden Goblet", description: "A shiny golden goblet.") }
  let(:server) { Server.create(name: "Server1") }

  let(:treasure_find) { TreasureFind.create(user: user, treasure: treasure, server: server, found_at: Time.now) }

  describe "Validations" do
    it "should validate presence of user_id" do
      treasure_find.user_id = nil
      expect(treasure_find).not_to be_valid
      expect(treasure_find.errors[:user_id]).to include("can't be blank")
    end

    it "should validate presence of treasure_id" do
      treasure_find.treasure_id = nil
      expect(treasure_find).not_to be_valid
      expect(treasure_find.errors[:treasure_id]).to include("can't be blank")
    end

    it "should validate presence of server_id" do
      treasure_find.server_id = nil
      expect(treasure_find).not_to be_valid
      expect(treasure_find.errors[:server_id]).to include("can't be blank")
    end

    it "should validate presence of found_at" do
      treasure_find.found_at = nil
      expect(treasure_find).not_to be_valid
      expect(treasure_find.errors[:found_at]).to include("can't be blank")
    end
  end

  describe "Associations" do
    it "should belong to a user" do
      expect(treasure_find.user).to eq(user)
    end

    it "should belong to a treasure" do
      expect(treasure_find.treasure).to eq(treasure)
    end

    it "should belong to a server" do
      expect(treasure_find.server).to eq(server)
    end
  end

  describe "Uniqueness Validation" do
    it "should not allow a duplicate treasure find for the same user, treasure, and server" do
      first_find = TreasureFind.create(user: user, treasure: treasure, server: server, found_at: Time.now)
      expect(first_find).to be_valid

      duplicate_find = TreasureFind.create(user: user, treasure: treasure, server: server, found_at: Time.now)
      expect(duplicate_find).not_to be_valid
      expect(duplicate_find.errors[:user_id]).to include("has already been taken")
    end
  end
end

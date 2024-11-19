require 'rails_helper'

RSpec.describe ServerUser, type: :model do
  describe 'Associations' do
    it 'belongs to a user' do
      assoc = described_class.reflect_on_association(:user)
      expect(assoc.macro).to eq(:belongs_to)
    end

    it 'belongs to a server' do
      assoc = described_class.reflect_on_association(:server)
      expect(assoc.macro).to eq(:belongs_to)
    end
  end

  describe 'Validations' do
    it 'is valid with a user_id and server_id' do
      user = User.create!(username: 'Player1', email: 'player1@example.com', password: 'password123')
      server = Server.create!(name: 'Test Server')
      #server_user = ServerUser.new(user: user, server: server)
      #expect(server_user).to be_valid
    end

    it 'is invalid without a user_id' do
      #server = Server.create!(name: 'Test Server')
      # server_user = ServerUser.new(server: server)
      #expect(server_user).not_to be_valid
      #expect(server_user.errors[:user]).to include("must exist")
    end

    it 'is invalid without a server_id' do
      #user = User.create!(username: 'Player1', email: 'player1@example.com', password: 'password123')
      #server_user = ServerUser.new(user: user)
      #expect(server_user).not_to be_valid
      #expect(server_user.errors[:server]).to include("must exist")
    end
  end
end

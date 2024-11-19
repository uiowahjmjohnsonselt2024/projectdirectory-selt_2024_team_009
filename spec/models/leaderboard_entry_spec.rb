require 'rails_helper'

RSpec.describe LeaderboardEntry, type: :model do
  describe 'Validations' do
    let(:user) { User.create!(username: 'Player1', email: 'player1@example.com', password: 'password123') }

    it 'is valid with valid attributes' do
      #entry = LeaderboardEntry.new(user_id: user.id, score: 100)
      #expect(entry).to be_valid
    end

    it 'is invalid without a user_id' do
      #entry = LeaderboardEntry.new(score: 100)
      #expect(entry).not_to be_valid
      #expect(entry.errors[:user_id]).to include("can't be blank")
    end

    it 'is invalid without a score' do
      #entry = LeaderboardEntry.new(user_id: user.id)
      #expect(entry).not_to be_valid
      #expect(entry.errors[:score]).to include("can't be blank")
    end
  end

  describe 'Associations' do
    it 'belongs to a user' do
      assoc = described_class.reflect_on_association(:user)
      expect(assoc.macro).to eq(:belongs_to)
    end
  end

  describe 'Leaderboard ordering' do
    let(:user1) { User.create!(username: 'Player1', email: 'player1@example.com', password: 'password123') }
    let(:user2) { User.create!(username: 'Player2', email: 'player2@example.com', password: 'password456') }

    before do
      LeaderboardEntry.create!(user_id: user1.id, score: 200)
      LeaderboardEntry.create!(user_id: user2.id, score: 300)
    end

    it 'orders leaderboard entries by score in descending order' do
      leaderboard = LeaderboardEntry.order(score: :desc)
      expect(leaderboard.first.user).to eq(user2)
      expect(leaderboard.second.user).to eq(user1)
    end
  end
end

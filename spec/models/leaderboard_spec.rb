require 'rails_helper'

RSpec.describe Leaderboard, type: :model do
  let!(:player1) { Player.create(name: "Player One", score: 150, created_at: 2.years.ago) }
  let!(:player2) { Player.create(name: "Player Two", score: 300, created_at: 1.year.ago) }
  let!(:player3) { Player.create(name: "Player Three", score: 200, created_at: 6.months.ago) }

  describe "Leaderboard functionality" do
    context "ordering players by score" do
      it "ranks players with the highest score at the top" do
        Leaderboard.update
        expect(leaderboard.first).to eq(player2)
        expect(leaderboard.second).to eq(player3)
        expect(leaderboard.last).to eq(player1)
      end
    end

    context "leaderboard entry content" do
      it "includes player name, account age, and score" do

        expect(leaderboard).to include(
                                 { name: "Player Two", account_age: 1, score: 300 },
                                 { name: "Player Three", account_age: 0, score: 200 },
                                 { name: "Player One", account_age: 2, score: 150 }
                               )
      end
    end
  end
end

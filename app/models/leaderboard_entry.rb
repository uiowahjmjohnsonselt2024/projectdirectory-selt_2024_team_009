class LeaderboardEntry < ApplicationRecord
  belongs_to :leaderboard
  belongs_to :user
end

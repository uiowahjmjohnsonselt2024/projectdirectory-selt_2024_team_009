class AddForeignKeysToLeaderboardEntries < ActiveRecord::Migration[7.2]
  def change
    add_foreign_key :leaderboard_entries, :leaderboards, column: :leaderboard_id
    add_foreign_key :leaderboard_entries, :users, column: :user_id
  end
end

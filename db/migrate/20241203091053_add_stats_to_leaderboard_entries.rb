class AddStatsToLeaderboardEntries < ActiveRecord::Migration[7.2]
  def change
    add_column :leaderboard_entries, :remaining_ap, :integer, default: 0
    add_column :leaderboard_entries, :cells_occupied, :integer, default: 0
  end
end

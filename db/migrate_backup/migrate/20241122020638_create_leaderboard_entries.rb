class CreateLeaderboardEntries < ActiveRecord::Migration[7.2]
  def change
    create_table :leaderboard_entries do |t|
      t.integer :leaderboard_id, null: false
      t.integer :user_id, null: false
      t.integer :points
      t.integer :rank

      t.timestamps
    end
  end
end

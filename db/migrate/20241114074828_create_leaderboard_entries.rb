class CreateLeaderboardEntries < ActiveRecord::Migration[7.2]
  def change
    create_table :leaderboard_entries do |t|
      t.references :leaderboard, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.integer :points
      t.integer :rank

      t.timestamps
    end
  end
end

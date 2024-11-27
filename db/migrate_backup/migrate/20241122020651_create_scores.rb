class CreateScores < ActiveRecord::Migration[7.2]
  def change
    create_table :scores do |t|
      t.integer :user_id, null: false
      t.integer :server_id, null: false
      t.integer :points
      t.integer :level

      t.timestamps
    end
  end
end

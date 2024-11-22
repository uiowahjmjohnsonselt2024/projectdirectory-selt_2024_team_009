class CreateLeaderboards < ActiveRecord::Migration[7.2]
  def change
    create_table :leaderboards do |t|
      t.string :name
      t.string :scope
      t.integer :server_id, null: false

      t.timestamps
    end
  end
end

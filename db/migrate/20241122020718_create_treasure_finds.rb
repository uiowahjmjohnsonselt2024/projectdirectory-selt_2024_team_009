class CreateTreasureFinds < ActiveRecord::Migration[7.2]
  def change
    create_table :treasure_finds do |t|
      t.integer :user_id, null: false
      t.integer :treasure_id, null: false
      t.integer :server_id, null: false
      t.datetime :found_at

      t.timestamps
    end
  end
end

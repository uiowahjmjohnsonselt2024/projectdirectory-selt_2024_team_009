class CreateTreasureFinds < ActiveRecord::Migration[7.2]
  def change
    create_table :treasure_finds do |t|
      t.references :user, null: false, foreign_key: true
      t.references :treasure, null: false, foreign_key: true
      t.references :server, null: false, foreign_key: true
      t.datetime :found_at

      t.timestamps
    end
  end
end

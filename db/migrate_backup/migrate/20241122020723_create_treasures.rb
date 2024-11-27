class CreateTreasures < ActiveRecord::Migration[7.2]
  def change
    create_table :treasures do |t|
      t.string :name
      t.text :description
      t.integer :points
      t.integer :item_id, null: false
      t.string :unlock_criteria

      t.timestamps
    end
  end
end

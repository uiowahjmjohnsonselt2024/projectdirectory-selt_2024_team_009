class CreateTreasures < ActiveRecord::Migration[7.2]
  def change
    create_table :treasures do |t|
      t.string :name
      t.text :description
      t.integer :points
      t.references :item, null: false, foreign_key: true
      t.string :unlock_criteria

      t.timestamps
    end
  end
end

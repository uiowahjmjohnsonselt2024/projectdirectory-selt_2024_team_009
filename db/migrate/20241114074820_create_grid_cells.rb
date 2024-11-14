class CreateGridCells < ActiveRecord::Migration[7.2]
  def change
    create_table :grid_cells do |t|
      t.references :server, null: false, foreign_key: true
      t.integer :x
      t.integer :y
      t.references :content, null: false, foreign_key: true
      t.references :treasure, null: false, foreign_key: true

      t.timestamps
    end
  end
end

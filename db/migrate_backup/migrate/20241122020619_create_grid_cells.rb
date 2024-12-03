class CreateGridCells < ActiveRecord::Migration[7.2]
  def change
    create_table :grid_cells do |t|
      t.integer :server_id, null: false
      t.integer :x
      t.integer :y
      t.integer :content_id, null: false
      t.integer :treasure_id, null: false

      t.timestamps
    end
  end
end

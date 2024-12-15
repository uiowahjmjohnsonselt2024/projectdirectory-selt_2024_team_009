class AddUniqueIndexToGridCells < ActiveRecord::Migration[7.2]
  def change
    add_index :grid_cells, [:server_id, :x, :y], unique: true
  end
end

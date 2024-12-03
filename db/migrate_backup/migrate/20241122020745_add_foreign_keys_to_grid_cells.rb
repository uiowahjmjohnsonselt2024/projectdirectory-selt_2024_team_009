class AddForeignKeysToGridCells < ActiveRecord::Migration[7.2]
  def change
    add_foreign_key :grid_cells, :servers
    add_foreign_key :grid_cells, :contents
    add_foreign_key :grid_cells, :treasures
  end
end

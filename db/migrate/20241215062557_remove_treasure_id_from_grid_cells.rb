class RemoveTreasureIdFromGridCells < ActiveRecord::Migration[7.2]
  def change
    remove_column :grid_cells, :treasure_id, :integer
  end
end

class AddOwnerAndObstacleToGridCells < ActiveRecord::Migration[7.2]
  def change
    add_column :grid_cells, :owner_id, :integer
    add_column :grid_cells, :obstacle, :boolean, default: false
  end
end

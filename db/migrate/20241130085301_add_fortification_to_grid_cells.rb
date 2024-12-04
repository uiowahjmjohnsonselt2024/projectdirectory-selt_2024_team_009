class AddFortificationToGridCells < ActiveRecord::Migration[7.2]
  def change
    add_column :grid_cells, :fortified, :integer
  end
end

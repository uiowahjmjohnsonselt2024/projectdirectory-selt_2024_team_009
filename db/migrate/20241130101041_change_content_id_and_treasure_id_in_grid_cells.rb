class ChangeContentIdAndTreasureIdInGridCells < ActiveRecord::Migration[7.2]
  def change
    change_column_null :grid_cells, :content_id, true
    change_column_null :grid_cells, :treasure_id, true
  end
end

class AddGameIdAndGridCellIdToTreasures < ActiveRecord::Migration[7.2]
  def change
    add_reference :treasures, :game, null: false, foreign_key: true
    add_reference :treasures, :grid_cell, null: false, foreign_key: true
  end
end

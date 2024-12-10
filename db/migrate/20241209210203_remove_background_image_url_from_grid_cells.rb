class RemoveBackgroundImageUrlFromGridCells < ActiveRecord::Migration[7.2]
  def change
    remove_column :grid_cells, :background_image_url, :string
  end
end

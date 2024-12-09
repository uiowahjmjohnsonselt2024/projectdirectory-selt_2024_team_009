class AddBackgroundImageUrlToGridCells < ActiveRecord::Migration[7.2]
  def change
    add_column :grid_cells, :background_image_url, :string
  end
end

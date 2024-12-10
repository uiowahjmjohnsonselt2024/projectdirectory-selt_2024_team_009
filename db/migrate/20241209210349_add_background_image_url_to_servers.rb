class AddBackgroundImageUrlToServers < ActiveRecord::Migration[7.2]
  def change
    add_column :servers, :background_image_url, :string
  end
end

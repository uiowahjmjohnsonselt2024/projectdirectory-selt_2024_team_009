class AddImageUrlToItems < ActiveRecord::Migration[7.2]
  def change
    add_column :items, :image_url, :string
  end
end

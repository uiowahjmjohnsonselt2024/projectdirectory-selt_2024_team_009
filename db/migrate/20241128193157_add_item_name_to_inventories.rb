class AddItemNameToInventories < ActiveRecord::Migration[7.2]
  def change
    add_column :inventories, :item_name, :string
  end
end

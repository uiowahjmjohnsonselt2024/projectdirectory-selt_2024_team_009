class AddForeignKeysToInventories < ActiveRecord::Migration[7.2]
  def change
    add_foreign_key :inventories, :users, column: :user_id
    add_foreign_key :inventories, :items, column: :item_id
  end
end

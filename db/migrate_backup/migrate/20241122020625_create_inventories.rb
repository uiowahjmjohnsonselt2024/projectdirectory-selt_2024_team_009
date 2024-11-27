class CreateInventories < ActiveRecord::Migration[7.2]
  def change
    create_table :inventories do |t|
      t.integer :user_id, null: false
      t.integer :item_id, null: false
      t.integer :quantity

      t.timestamps
    end
  end
end

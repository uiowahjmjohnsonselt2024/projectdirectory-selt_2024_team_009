class AddServerUserIdToInventories < ActiveRecord::Migration[7.2]
  def change
    add_column :inventories, :server_user_id, :integer
  end
end

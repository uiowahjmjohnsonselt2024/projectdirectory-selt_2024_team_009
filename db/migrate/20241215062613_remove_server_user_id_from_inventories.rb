class RemoveServerUserIdFromInventories < ActiveRecord::Migration[7.2]
  def change
    remove_column :inventories, :server_user_id, :integer
  end
end

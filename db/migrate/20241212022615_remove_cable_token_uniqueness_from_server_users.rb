class RemoveCableTokenUniquenessFromServerUsers < ActiveRecord::Migration[7.2]
  def change
    remove_index :server_users, :cable_token if index_exists?(:server_users, :cable_token)
  end
end

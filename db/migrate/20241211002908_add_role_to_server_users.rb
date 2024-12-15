class AddRoleToServerUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :server_users, :role, :integer, null: false, default: 0
    # Adding an index can improve query performance on the role column
    add_index :server_users, :role
  end
end

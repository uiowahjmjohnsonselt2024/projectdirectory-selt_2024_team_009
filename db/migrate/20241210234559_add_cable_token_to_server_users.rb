class AddCableTokenToServerUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :server_users, :cable_token, :string
    add_index :server_users, :cable_token, unique: true
  end
end

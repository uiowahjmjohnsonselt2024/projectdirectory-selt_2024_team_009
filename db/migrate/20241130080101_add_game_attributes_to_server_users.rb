class AddGameAttributesToServerUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :server_users, :total_ap, :integer, default: 200
    add_column :server_users, :turn_ap, :integer, default: 2
    add_column :server_users, :shard_balance, :integer, default: 0
    add_column :server_users, :symbol, :string
    add_column :server_users, :turn_order, :integer
  end
end

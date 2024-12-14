class AddCableTokenToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :cable_token, :string
    add_index :users, :cable_token, unique: true
  end
end

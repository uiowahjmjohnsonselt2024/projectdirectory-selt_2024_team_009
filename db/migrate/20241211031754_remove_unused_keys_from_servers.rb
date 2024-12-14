class RemoveUnusedKeysFromServers < ActiveRecord::Migration[7.2]
  def change
    remove_column :servers, :cable_token, :string
  end
end

class RemoveUnusedKeysFromServers < ActiveRecord::Migration[7.2]
  def change
    if column_exists?(:servers, :cable_token)
      remove_column :servers, :cable_token, :string
    end
  end
end

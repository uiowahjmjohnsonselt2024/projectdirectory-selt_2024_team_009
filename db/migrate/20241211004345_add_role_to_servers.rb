class AddRoleToServers < ActiveRecord::Migration[7.2]
  def change
    add_column :servers, :role, :string
  end
end

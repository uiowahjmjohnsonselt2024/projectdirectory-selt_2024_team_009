class SetDefaultRoleForServerUsers < ActiveRecord::Migration[7.2]
  def change
    change_column_default :server_users, :role, from: nil, to: 'player'
  end
end

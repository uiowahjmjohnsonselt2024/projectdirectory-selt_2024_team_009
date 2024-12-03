class AddStatusAndCurrentTurnToServers < ActiveRecord::Migration[7.2]
  def change
    add_column :servers, :status, :string, default: 'pending'
    add_column :servers, :current_turn_server_user_id, :integer
  end
end

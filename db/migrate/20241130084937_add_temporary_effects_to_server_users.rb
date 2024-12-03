class AddTemporaryEffectsToServerUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :server_users, :can_move_diagonally, :boolean
    add_column :server_users, :diagonal_moves_left, :integer
    add_column :server_users, :mirror_shield, :boolean
    add_column :server_users, :turns_skipped, :integer
  end
end

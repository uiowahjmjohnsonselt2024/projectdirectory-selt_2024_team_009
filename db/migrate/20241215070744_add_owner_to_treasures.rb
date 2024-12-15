class AddOwnerToTreasures < ActiveRecord::Migration[7.2]
  def change
    add_reference :treasures, :owner, foreign_key: { to_table: :server_users }
    change_column_null :treasures, :game_id, false
  end
end

class AddGameIdToMessages < ActiveRecord::Migration[7.2]
  def change
    add_column :messages, :game_id, :integer
  end
end

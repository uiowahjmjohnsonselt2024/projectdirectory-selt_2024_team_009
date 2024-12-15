class AddServerIdToGames < ActiveRecord::Migration[7.2]
  def change
    add_reference :games, :server, null: false, foreign_key: true
  end
end

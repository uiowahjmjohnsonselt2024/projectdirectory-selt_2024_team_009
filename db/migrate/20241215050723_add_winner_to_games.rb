class AddWinnerToGames < ActiveRecord::Migration[7.2]
  def change
    add_column :games, :winner, :string
  end
end

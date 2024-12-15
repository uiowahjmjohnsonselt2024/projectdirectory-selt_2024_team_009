class AddTurnCountToServers < ActiveRecord::Migration[7.2]
  def change
    add_column :servers, :turn_count, :integer
  end
end

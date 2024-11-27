class AddForeignKeysToLeaderboards < ActiveRecord::Migration[7.2]
  def change
    add_foreign_key :leaderboards, :servers, column: :server_id
  end
end

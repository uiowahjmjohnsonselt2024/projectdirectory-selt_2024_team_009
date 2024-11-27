class AddForeignKeysToScores < ActiveRecord::Migration[7.2]
  def change
    add_foreign_key :scores, :users, column: :user_id
    add_foreign_key :scores, :servers, column: :server_id
  end
end
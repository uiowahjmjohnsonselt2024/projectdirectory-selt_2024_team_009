class AddForeignKeysToServerUsers < ActiveRecord::Migration[7.2]
  def change
    add_foreign_key :server_users, :users, column: :user_id
    add_foreign_key :server_users, :servers, column: :server_id
  end
end

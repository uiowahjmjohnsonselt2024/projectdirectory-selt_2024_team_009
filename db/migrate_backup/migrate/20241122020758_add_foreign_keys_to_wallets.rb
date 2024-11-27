class AddForeignKeysToWallets < ActiveRecord::Migration[7.2]
  def change
    add_foreign_key :wallets, :users, column: :user_id
  end
end

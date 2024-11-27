class AddForeignKeysToTransactions < ActiveRecord::Migration[7.2]
  def change
    add_foreign_key :transactions, :users, column: :user_id
    add_foreign_key :transactions, :items, column: :item_id
  end
end

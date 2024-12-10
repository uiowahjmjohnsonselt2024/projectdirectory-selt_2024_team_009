class ChangeItemIdToNullableInTransactions < ActiveRecord::Migration[7.2]
  def change
    change_column_null :transactions, :item_id, true
  end
end

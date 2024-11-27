class AddForeignKeysToTreasures < ActiveRecord::Migration[7.2]
  def change
    add_foreign_key :treasures, :items, column: :item_id
  end
end

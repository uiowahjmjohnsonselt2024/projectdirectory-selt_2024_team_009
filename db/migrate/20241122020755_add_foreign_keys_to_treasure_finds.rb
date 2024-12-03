class AddForeignKeysToTreasureFinds < ActiveRecord::Migration[7.2]
  def change
    add_foreign_key :treasure_finds, :users, column: :user_id
    add_foreign_key :treasure_finds, :treasures, column: :treasure_id
    add_foreign_key :treasure_finds, :servers, column: :server_id
  end
end

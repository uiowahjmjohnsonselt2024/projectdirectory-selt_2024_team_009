class CreateWallets < ActiveRecord::Migration[7.2]
  def change
    create_table :wallets do |t|
      t.integer :user_id, null: false
      t.decimal :balance, precision: 10, scale: 2

      t.timestamps
    end
  end
end

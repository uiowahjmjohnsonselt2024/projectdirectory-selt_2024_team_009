class CreateTransactions < ActiveRecord::Migration[7.2]
  def change
    create_table :transactions do |t|
      t.integer :user_id, null: false
      t.string :transaction_type
      t.decimal :amount, precision: 10, scale: 2
      t.string :currency
      t.string :payment_method
      t.integer :item_id, null: true
      t.integer :quantity
      t.text :description

      t.timestamps
    end
  end
end

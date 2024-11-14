class CreateTransactions < ActiveRecord::Migration[7.2]
  def change
    create_table :transactions do |t|
      t.references :user, null: false, foreign_key: true
      t.string :transaction_type
      t.decimal :amount, precision: 10, scale: 2
      t.string :currency
      t.string :payment_method
      t.references :item, null: false, foreign_key: true
      t.integer :quantity
      t.text :description

      t.timestamps
    end
  end
end

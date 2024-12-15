class CreateItems < ActiveRecord::Migration[7.2]
  def change
    create_table :items do |t|
      t.string :name
      t.text :description
      t.decimal :price, precision: 10, scale: 2
      t.string :category
      t.integer :required_level

      t.timestamps
    end
  end
end

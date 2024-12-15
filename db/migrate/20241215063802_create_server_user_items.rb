class CreateServerUserItems < ActiveRecord::Migration[7.2]
  def change
    unless table_exists?(:server_user_items)
      create_table :server_user_items do |t|
        t.references :server_user, null: false, foreign_key: true
        t.references :item, null: false, foreign_key: true
        t.boolean :used, default: false
        t.timestamps
      end
    end
  end
end

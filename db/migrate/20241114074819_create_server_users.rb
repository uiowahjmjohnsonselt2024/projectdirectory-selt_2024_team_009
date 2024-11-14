class CreateServerUsers < ActiveRecord::Migration[7.2]
  def change
    create_table :server_users do |t|
      t.references :user, null: false, foreign_key: true
      t.references :server, null: false, foreign_key: true
      t.integer :current_position_x
      t.integer :current_position_y

      t.timestamps
    end
  end
end

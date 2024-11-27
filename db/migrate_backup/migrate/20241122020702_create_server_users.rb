class CreateServerUsers < ActiveRecord::Migration[7.2]
  def change
    create_table :server_users do |t|
      t.integer :user_id, null: false
      t.integer :server_id, null: false
      t.integer :current_position_x
      t.integer :current_position_y

      t.timestamps
    end
  end
end

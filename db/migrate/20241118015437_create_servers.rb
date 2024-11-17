class CreateServers < ActiveRecord::Migration[7.2]
  def change
    create_table :servers do |t|
      t.string :name
      t.integer :max_players
      t.integer :created_by

      t.timestamps
    end
  end
end

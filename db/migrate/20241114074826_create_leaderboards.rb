class CreateLeaderboards < ActiveRecord::Migration[7.2]
  def change
    create_table :leaderboards do |t|
      t.string :name
      t.string :scope
      t.references :server, null: false, foreign_key: true

      t.timestamps
    end
  end
end

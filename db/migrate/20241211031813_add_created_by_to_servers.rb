class AddCreatedByToServers < ActiveRecord::Migration[7.2]
  def change
    add_foreign_key :servers, :users, column: :created_by # Optional: Enforce foreign key relationship
    add_index :servers, :created_by # Optional: Add an index for faster queries
  end
end

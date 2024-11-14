class AddUsernameToUsers < ActiveRecord::Migration[7.2]
  def change
    unless column_exists?(:users, :username)
      add_column :users, :username, :string
    end

    unless index_exists?(:users, :username)
      add_index :users, :username, unique: true
    end
  end
end

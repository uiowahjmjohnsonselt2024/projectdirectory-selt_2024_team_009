class AddRecoverableToUsers < ActiveRecord::Migration[7.2]
  def change
    # Check if the column doesn't exist before adding it
    add_column :users, :reset_password_token, :string unless column_exists?(:users, :reset_password_token)
    add_index :users, :reset_password_token, unique: true unless index_exists?(:users, :reset_password_token)

    # Check if reset_password_sent_at column exists before adding it
    add_column :users, :reset_password_sent_at, :datetime unless column_exists?(:users, :reset_password_sent_at)
  end
end

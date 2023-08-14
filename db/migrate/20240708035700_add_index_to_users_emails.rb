class AddIndexToUsersEmails < ActiveRecord::Migration[7.0]
  def change
    add_index :users, :emails, unique: true
  end
end

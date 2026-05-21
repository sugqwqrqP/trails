class AddUniqueIndexToUsersLoginId < ActiveRecord::Migration[7.0]
  def change
    add_index :users, :login_id, unique: true
  end
end

class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.string  :login_id, null: false
      t.string  :password_digest, null: false
      t.string  :user_fullname, null: false
      t.integer :role, null: false, default: 0
      t.timestamps
    end
  end
end

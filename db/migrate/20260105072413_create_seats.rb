class CreateSeats < ActiveRecord::Migration[7.0]
  def change
    create_table :seats do |t|
      t.references :car, null: false, foreign_key: true
      t.integer :row, null: false
      t.string :column, null: false

      t.timestamps
    end

    add_index :seats, [:car_id, :row, :column], unique: true
  end
end

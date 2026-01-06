class CreateReservations < ActiveRecord::Migration[7.0]
  def change
    create_table :reservations do |t|
      t.references :user, null: false, foreign_key: true
      t.references :run,  null: false, foreign_key: true

      t.references :departure_station, null: false, foreign_key: { to_table: :stations }
      t.references :arrival_station,   null: false, foreign_key: { to_table: :stations }

      t.string  :holder_name, null: false
      t.boolean :is_issued, null: false, default: false

      t.timestamps
    end
  end
end

class CreateStations < ActiveRecord::Migration[7.0]
  def change
    create_table :stations do |t|
      t.string  :station_name, null: false
      t.integer :station_order, null: false

      t.timestamps
    end
  end
end

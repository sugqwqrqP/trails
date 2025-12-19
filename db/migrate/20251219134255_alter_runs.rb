class AlterRuns < ActiveRecord::Migration[7.0]
  def change
    add_column :runs, :run_number, :integer, null: false
    add_column :runs, :run_on, :date, null: false
    add_column :runs, :is_up, :boolean, null: false

    add_column :runs, :departure_station_name, :string, null: false
    add_column :runs, :arrival_station_name, :string, null: false
    add_column :runs, :departure_time, :time, null: false
    add_column :runs, :arrival_time, :time, null: false
  end
end

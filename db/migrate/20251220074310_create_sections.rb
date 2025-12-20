class CreateSections < ActiveRecord::Migration[7.0]
  def change
    create_table :sections do |t|
      t.references :run_type, null: false, foreign_key: true
      t.references :from_station, null: false, foreign_key: true
      t.references :to_station, null: false, foreign_key: true
      t.integer :section_order
      t.integer :required_time
      t.integer :fee

      t.timestamps
    end
  end
end

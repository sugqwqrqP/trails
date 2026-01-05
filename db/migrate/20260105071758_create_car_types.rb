class CreateCarTypes < ActiveRecord::Migration[7.0]
  def change
    create_table :car_types do |t|
      t.string :name, null: false

      t.timestamps
    end
  end
end

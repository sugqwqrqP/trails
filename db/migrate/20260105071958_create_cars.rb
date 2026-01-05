class CreateCars < ActiveRecord::Migration[7.0]
  def change
    create_table :cars do |t|
      t.references :run, null: false, foreign_key: true
      t.references :car_type, null: false, foreign_key: true
      t.integer :number, null: false

      t.timestamps
    end

    # 同じ便に同じ号車番号は1つだけ
    add_index :cars, [:run_id, :number], unique: true
  end
end

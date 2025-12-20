class CreateRunTypes < ActiveRecord::Migration[7.0]
  def change
    create_table :run_types do |t|
      t.string :name, null: false
      t.timestamps
    end
  end
end

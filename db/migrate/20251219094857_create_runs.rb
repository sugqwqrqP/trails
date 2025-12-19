class CreateRuns < ActiveRecord::Migration[7.0]
  def change
    create_table :runs do |t|
      t.string :name

      t.timestamps
    end
  end
end

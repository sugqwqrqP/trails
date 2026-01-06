class RemoveNameFromRuns < ActiveRecord::Migration[7.0]
  def change
    remove_column :runs, :name, :string
  end
end

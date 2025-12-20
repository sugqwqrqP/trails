class UpdateRunsAndRunType < ActiveRecord::Migration[7.0]
  def change
    # run_typeとの関連付けを追加
    add_reference :runs, :run_type, null: false, foreign_key: true

    # 不要なカラムを削除
    remove_column :runs, :departure_station_name, :string
    remove_column :runs, :arrival_station_name, :string
  end
end

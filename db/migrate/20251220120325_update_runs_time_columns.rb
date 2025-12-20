class UpdateRunsTimeColumns < ActiveRecord::Migration[7.0]
  def change
    # 到着時刻は計算結果なので削除
    remove_column :runs, :arrival_time, :time

    # 始発駅の発車時刻に意味を明確化
    rename_column :runs, :departure_time, :first_station_departure_time
  end
end

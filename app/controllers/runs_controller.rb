class RunsController < ApplicationController
  def index
    @results = []   
    # ==========
    # 0) パラメータ取得（フォーム側のnameに合わせて変えてOK）
    # ==========
    from_station_id = params[:from_station_id].presence
    to_station_id   = params[:to_station_id].presence
    run_on_str      = params[:run_on].presence # "2025-12-20" みたいな想定
    time_str        = params[:time].presence   # "10:30" みたいな想定
    time_basis      = params[:time_basis].presence # "departure" or "arrival"

    # 入力が揃ってないなら全便表示（とりあえず落とさない）
    unless from_station_id && to_station_id && run_on_str
      @runs = Run.all
      return
    end

    from_station = Station.find(from_station_id)
    to_station   = Station.find(to_station_id)
    run_on       = Date.parse(run_on_str)

    # ==========
    # 1) station_order を比較して上り/下りを決める
    #   - seeds: 東京→新大阪は is_up=false, 新大阪→東京は is_up=true
    #   - station_order が大きい方から小さい方へ向かう = 上り = is_up=true
    # ==========
    desired_is_up = (from_station.station_order > to_station.station_order)

    # ==========
    # 2) run_on と is_up でまず絞る
    # ==========
    runs = Run
      .includes(run_type: { sections: [:from_station, :to_station] })
      .where(run_on: run_on, is_up: desired_is_up)

    # ==========
    # 3) sections に「乗車駅・降車駅が含まれる」便だけ残す
    #   - ここは RunType#required_travel_time が例外を投げる可能性があるので rescue
    # ==========
    runs = runs.select do |run|
      begin
        run.run_type.required_travel_time(from_station: from_station, to_station: to_station) > 0
      rescue ActiveRecord::RecordNotFound
        false
      end
    end

    # ==========
    # 4) 出発/到着時刻を算出
    #   - first_station_departure_time は「始発駅の時刻」
    #   - 始発駅は is_up により東京/新大阪で決定
    # ==========
    tokyo      = Station.find_by!(station_name: "東京")
    shin_osaka = Station.find_by!(station_name: "新大阪")

    results = runs.map do |run|
      first_station = run.is_up ? shin_osaka : tokyo

      # 始発駅→乗車駅 のオフセット（分）
      dep_offset_min = run.run_type.required_travel_time(
        from_station: first_station,
        to_station: from_station
      )

      # 始発駅→降車駅 のオフセット（分）
      arr_offset_min = run.run_type.required_travel_time(
        from_station: first_station,
        to_station: to_station
      )

      travel_min = run.run_type.required_travel_time(
        from_station: from_station,
        to_station: to_station
      )

      first_time = Time.zone.parse("#{run.run_on} #{run.first_station_departure_time.strftime('%H:%M')}")

      departure_time = first_time + dep_offset_min.minutes
      arrival_time   = first_time + arr_offset_min.minutes

      {
        run: run,
        departure_time: departure_time,
        arrival_time: arrival_time,
        travel_min: travel_min
      }
    end

    # ==========
    # 5) 指定時刻に近い順にソート
    #   - time_basis が arrival なら arrival 基準
    #   - 未指定なら departure_time 昇順
    # ==========
    if time_str
      target = Time.zone.parse("#{run_on} #{time_str}")

      key = (time_basis == "arrival") ? :arrival_time : :departure_time

      results.sort_by! do |h|
        (h[key] - target).abs
      end
    else
      results.sort_by! { |h| h[:departure_time] }
    end

    # ==========
    # ビューに渡す
    # ==========
    @results = results
  end
end

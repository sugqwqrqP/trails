class RunsController < ApplicationController
  DISPLAY_LIMIT = 5

  def index
    @results = []
    @has_more = false

    # ==========
    # 0) params
    # ==========
    departure_station_id = params[:departure_station_id].presence
    arrival_station_id   = params[:arrival_station_id].presence
    run_on_str           = params[:run_on].presence
    time_str             = params[:time].presence
    time_basis           = params[:time_basis].presence
    offset               = params[:offset].to_i || 0

    unless departure_station_id && arrival_station_id && run_on_str
      @runs = Run.all
      return
    end

    departure_station = Station.find(departure_station_id)
    arrival_station   = Station.find(arrival_station_id)
    run_on             = Date.parse(run_on_str)

    # ==========
    # バリデーション
    # ==========
    if departure_station_id == arrival_station_id
      @search_error = "発駅と着駅は異なる駅を指定してください"
      return
    end

    if run_on < Date.current
      @search_error = "過去の日付は指定できません"
      return
    end

    if run_on > Date.current + 14
      @search_error = "2週間後以降の便は検索できません"
      return
    end

    if run_on == Date.current && time_str.present?
      target_time = Time.zone.parse("#{run_on} #{time_str}")

      # その時間まではOK
      if target_time < Time.zone.now - 1.minute
        @search_error = "過去の時刻は指定できません"
        return
      end
    end

    # ==========
    # 1) 上り下り判定
    # ==========
    desired_is_up =
      departure_station.station_order > arrival_station.station_order

    # ==========
    # 2) run_on / is_up で絞る
    # ==========
    runs = Run
      .includes(run_type: { sections: [:from_station, :to_station] })
      .where(run_on: run_on, is_up: desired_is_up)

    # ==========
    # 3) 乗車可能な便だけ残す（軽い）
    # ==========
    candidates = runs.select do |run|
      begin
        run.run_type.required_travel_time(
          from_station: departure_station,
          to_station: arrival_station
        )
      rescue ActiveRecord::RecordNotFound
        false
      end
    end

    # ==========
    # 4) 時刻計算（まだ空席は見ない）
    # ==========
    basic_results = candidates.map do |run|
      {
        run: run,
        departure_time: run.departure_time_at(departure_station),
        arrival_time:   run.arrival_time_at(arrival_station),
        travel_min: run.run_type.required_travel_time(
          from_station: departure_station,
          to_station: arrival_station
        )
      }
    end

    # ==========
    # 5) 並び替え（軽い）
    # ==========
    if time_str.present?
      target = Time.zone.parse("#{run_on} #{time_str}")
      key = (time_basis == "arrival") ? :arrival_time : :departure_time

      basic_results.sort_by! { |h| (h[key] - target).abs }
    else
      basic_results.sort_by! { |h| h[:departure_time] }
    end

    # ==========
    # 6) 表示対象だけ空席計算（重い）
    # ==========
    slice = basic_results.slice(offset, DISPLAY_LIMIT) || []

    @results = slice.map do |h|
      run = h[:run]

      h.merge(
        availability: {
          reserved: availability(run, "reserved", departure_station, arrival_station),
          green:    availability(run, "green",    departure_station, arrival_station),
          fabulous: availability(run, "fabulous", departure_station, arrival_station)
        }
      )
    end

    # ==========
    # 7) もっと表示 判定
    # ==========
    offset = params[:offset].to_i
    limit  = DISPLAY_LIMIT

    @has_prev = offset > 0
    @has_next = basic_results.size > offset + limit

    @prev_offset = [offset - limit, 0].max
    @next_offset = offset + limit
  end

  private

  def availability(run, car_type, dep, arr)
    count = run.available_count(
      car_type_name: car_type,
      departure_station: dep,
      arrival_station: arr
    )

    {
      count: count,
      mark: run.availability_mark(car_type, count)
    }
  end

end

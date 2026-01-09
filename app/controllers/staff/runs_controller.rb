class Staff::RunsController < Staff::BaseController
  before_action :require_login
  before_action :require_staff

  def index
    @results = []   
    # ==========
    # 0) パラメータ取得（フォーム側のnameに合わせて変えてOK）
    # ==========
    departure_station_id = params[:departure_station_id].presence
    arrival_station_id   = params[:arrival_station_id].presence
    run_on_str      = params[:run_on].presence # "2025-12-20" みたいな想定
    time_str        = params[:time].presence   # "10:30" みたいな想定
    time_basis      = params[:time_basis].presence # "departure" or "arrival"

    # 入力が揃ってないなら全便表示（とりあえず落とさない）
    unless departure_station_id && arrival_station_id && run_on_str
      @runs = Run.all
      return
    end

    departure_station = Station.find(departure_station_id)
    arrival_station   = Station.find(arrival_station_id)
    @departure_station = departure_station
    @arrival_station   = arrival_station
    
    run_on       = Date.parse(run_on_str)

    # ===== 検索条件バリデーション =====

    # 発駅＝着駅
    if departure_station_id.present? && arrival_station_id.present? &&
      departure_station_id == arrival_station_id
      @search_error = "発駅と着駅は異なる駅を指定してください"
      @results = []
      render :index
      return
    end

    run_on = Date.parse(run_on_str)

    # 過去日付
    if run_on < Date.current
      @search_error = "過去の日付は指定できません"
      @results = []
      render :index
      return
    end

    # 15日以降
    if run_on > Date.current + 14
      @search_error = "2週間後以降の便は検索できません"
      @results = []
      render :index
      return
    end

    # 本日の過去時刻
    if run_on == Date.current && time_str.present?
      target_time = Time.zone.parse("#{run_on} #{time_str}")

      if target_time < Time.zone.now
        @search_error = "過去の時刻は指定できません"
        @results = []
        render :index
        return
      end
    end

    # ==========
    # 1) station_order を比較して上り/下りを決める
    #   - seeds: 東京→新大阪は is_up=false, 新大阪→東京は is_up=true
    #   - station_order が大きい方から小さい方へ向かう = 上り = is_up=true
    # ==========
    desired_is_up = (departure_station.station_order > arrival_station.station_order)

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
        run.run_type.required_travel_time(
          from_station: departure_station,
          to_station: arrival_station
        )
      rescue ActiveRecord::RecordNotFound
        false
      end
    end

    # ==========
    # 4) 出発/到着時刻を算出
    #   - first_station_departure_time は「始発駅の時刻」
    #   - 始発駅は is_up により東京/新大阪で決定
    # ==========

    results = runs.map do |run|
      departure_time = run.departure_time_at(departure_station)
      arrival_time   = run.arrival_time_at(arrival_station)

      travel_min = run.run_type.required_travel_time(
        from_station: departure_station,
        to_station: arrival_station
      )

      {
        run: run,
        departure_time: departure_time,
        arrival_time: arrival_time,
        travel_min: travel_min,

        availability: {
          reserved: {
            count: run.available_count(
              car_type_name: "reserved",
              departure_station: departure_station,
              arrival_station: arrival_station
            ),
            mark: run.availability_mark(
              "reserved",
              run.available_count(
                car_type_name: "reserved",
                departure_station: departure_station,
                arrival_station: arrival_station
              )
            )
          },
          green: {
            count: run.available_count(
              car_type_name: "green",
              departure_station: departure_station,
              arrival_station: arrival_station
            ),
            mark: run.availability_mark(
              "green",
              run.available_count(
                car_type_name: "green",
                departure_station: departure_station,
                arrival_station: arrival_station
              )
            )
          },
          fabulous: {
            count: run.available_count(
              car_type_name: "fabulous",
              departure_station: departure_station,
              arrival_station: arrival_station
            ),
            mark: run.availability_mark(
              "fabulous",
              run.available_count(
                car_type_name: "fabulous",
                departure_station: departure_station,
                arrival_station: arrival_station
              )
            )
          }
        }
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

  def show
    @run = Run.find(params[:id])


    @departure_station = Station.find(params[:departure_station_id])
    @arrival_station   = Station.find(params[:arrival_station_id])
    
    @reservations = @run.reservations
                        .includes(:seats, :departure_station, :arrival_station)
                        .order(created_at: :desc)
  end
end

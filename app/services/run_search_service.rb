class RunSearchService
  def self.call(params:, display_limit:, include_availability:, enable_pager:)
    new(params, display_limit, include_availability, enable_pager).call
  end

  def initialize(params, display_limit, include_availability, enable_pager)
    @params = params
    @display_limit = display_limit
    @include_availability = include_availability
    @enable_pager = enable_pager
  end

  def call
    results = []
    errors = []

    departure_station_id = @params[:departure_station_id].presence
    arrival_station_id   = @params[:arrival_station_id].presence
    run_on_str           = @params[:run_on].presence
    time_str             = @params[:time].presence
    time_basis           = @params[:time_basis].presence
    offset               = @params[:offset].to_i

    search_requested =
      @params[:departure_station_id].present? ||
      @params[:arrival_station_id].present? ||
      @params[:run_on].present? ||
      @params[:time].present?

    if search_requested
      errors << "出発駅を選択してください" if departure_station_id.blank?
      errors << "到着駅を選択してください" if arrival_station_id.blank?
      errors << "日付を選択してください" if run_on_str.blank?
    end
    return build_response(results, errors) unless search_requested

    departure_station = nil
    arrival_station   = nil
    run_on            = nil

    if departure_station_id.present?
      departure_station = Station.find_by(id: departure_station_id)
      errors << "出発駅が不正です" if departure_station.nil?
    end

    if arrival_station_id.present?
      arrival_station = Station.find_by(id: arrival_station_id)
      errors << "到着駅が不正です" if arrival_station.nil?
    end

    if run_on_str.present?
      begin
        run_on = Date.parse(run_on_str)
      rescue ArgumentError
        errors << "日付の形式が不正です"
      end
    end

    if departure_station && arrival_station
      if departure_station.id == arrival_station.id
        errors << "発駅と着駅は異なる駅を指定してください"
      end
    end

    if run_on
      min_run_on = Run.minimum(:run_on)
      max_run_on = Run.maximum(:run_on)

      if min_run_on.blank? || max_run_on.blank?
        errors << "現在、検索可能な便データがありません"
      elsif run_on < min_run_on || run_on > max_run_on
        errors << "デモデータ期間内の日付を指定してください（#{min_run_on.strftime("%Y/%m/%d")}〜#{max_run_on.strftime("%Y/%m/%d")}）"
      end

      if run_on == Date.current && time_str.present?
        begin
          target_time = Time.zone.parse("#{run_on} #{time_str}")
          if target_time < Time.zone.now - 1.minute
            errors << "過去の時刻は指定できません"
          end
        rescue ArgumentError, TypeError
          errors << "時刻の形式が不正です"
        end
      end
    end

    return build_response(results, errors) if errors.any?

    desired_is_up =
      departure_station.station_order > arrival_station.station_order

    runs = Run
      .includes(run_type: { sections: [:from_station, :to_station] })
      .where(run_on: run_on, is_up: desired_is_up)

    candidates = runs.select do |run|
      begin
        run.run_type.required_travel_time(
          from_station: departure_station,
          to_station: arrival_station
        )
        true
      rescue ActiveRecord::RecordNotFound
        false
      end
    end

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

    if time_str.present?
      target = Time.zone.parse("#{run_on} #{time_str}")
      key = (time_basis == "arrival") ? :arrival_time : :departure_time
      basic_results.sort_by! { |h| (h[key] - target).abs }
    else
      basic_results.sort_by! { |h| h[:departure_time] }
    end

    slice = if @display_limit
      basic_results.slice(offset, @display_limit) || []
    else
      basic_results
    end

    results = if @include_availability
      slice.map do |h|
        run = h[:run]
        h.merge(
          availability: {
            reserved: availability(run, "reserved", departure_station, arrival_station),
            green:    availability(run, "green",    departure_station, arrival_station),
            fabulous: availability(run, "fabulous", departure_station, arrival_station)
          }
        )
      end
    else
      slice
    end

    response = build_response(results, errors)
    response[:departure_station] = departure_station
    response[:arrival_station] = arrival_station

    if @display_limit && @enable_pager
      response[:has_prev] = offset > 0
      response[:has_next] = basic_results.size > offset + @display_limit
      response[:prev_offset] = [offset - @display_limit, 0].max
      response[:next_offset] = offset + @display_limit
    end

    response
  end

  private

  def build_response(results, errors)
    {
      results: results,
      errors: errors,
      has_prev: false,
      has_next: false,
      prev_offset: 0,
      next_offset: 0
    }
  end

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

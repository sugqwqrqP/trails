class Run < ApplicationRecord
  belongs_to :run_type
  has_many :cars
  has_many :reservations, dependent: :destroy

  before_create :assign_run_number

  validate :run_on_must_be_future, on: :manual_create
  validate :run_on_within_14_days, on: :manual_create
  validate :departure_time_not_too_early, on: :manual_create
  validate :departure_time_not_too_late, on: :manual_create
  validate :no_duplicate_run

  # ---- バリデーション ----

  def run_on_must_be_future
    return if run_on.blank?
    errors.add(:run_on, "は明日以降を指定してください") if run_on <= Date.current
  end

  def run_on_within_14_days
    return if run_on.blank?
    errors.add(:run_on, "は14日以内を指定してください") if run_on > Date.current + 14
  end

  def departure_time_not_too_early
    return if first_station_departure_time.blank?

    minutes =
      first_station_departure_time.hour * 60 +
      first_station_departure_time.min

    if minutes < 6 * 60
      errors.add(:first_station_departure_time, "は6:00以降を指定してください")
    end
  end

  def departure_time_not_too_late
    return if first_station_departure_time.blank?

    minutes =
      first_station_departure_time.hour * 60 +
      first_station_departure_time.min

    if minutes >= 21 * 60
      errors.add(:first_station_departure_time, "は21:00より前を指定してください")
    end
  end

  def no_duplicate_run
    return if run_on.blank? || first_station_departure_time.blank? || run_type.blank? || is_up.nil?

    if Run.exists?(
        run_on: run_on,
        first_station_departure_time: first_station_departure_time,
        run_type: run_type,
        is_up: is_up
      )
      errors.add(:base, "同一条件の便が既に存在します")
    end
  end

  def display_name
    "#{run_type.name} #{run_number}号"
  end

  def first_station
    is_up ?
      Station.find_by!(station_name: "新大阪") :
      Station.find_by!(station_name: "東京")
  end

  def first_departure_datetime
    Time.zone.local(
      run_on.year,
      run_on.month,
      run_on.day,
      first_station_departure_time.hour,
      first_station_departure_time.min
    )
  end

  def departure_time_at(station)
    offset =
      run_type.required_travel_time(
        from_station: first_station,
        to_station: station
      )

    first_departure_datetime + offset.minutes
  end

  def arrival_time_at(station)
    departure_time_at(station)
  end

  def available_count(
    car_type_name:,
    departure_station:,
    arrival_station:
  )
    cars
      .includes(:seats, :car_type)
      .select { |car| car.car_type.name == car_type_name }
      .flat_map(&:seats)
      .count do |seat|
        seat.available_for?(
          run: self,
          departure_station: departure_station,
          arrival_station: arrival_station
        )
      end
  end

  def assign_run_number
    return if run_number.present?

    base =
      case run_type.name
      when "のぞみ" then 1000
      when "ひかり" then 1500
      when "こだま" then 1700
      else
        raise "unknown run_type"
      end

    direction_offset = is_up ? 2 : 1

    # 同日・同種別・同方向の臨時便を数える
    count =
      Run.where(
        run_on: run_on,
        run_type: run_type,
        is_up: is_up
      )
      .where("run_number >= ?", base)
      .count

    self.run_number = base + direction_offset + count * 2
  end

  def availability_mark(car_type_name, count)
    case car_type_name
    when "fabulous"
      case count
      when 5..6 then "◎"
      when 3..4 then "◯"
      when 1..2 then "残り#{count}席"
      else "×"
      end
    else
      case count
      when 50.. then "◎"
      when 20..49 then "◯"
      when 1..19 then "残り#{count}席"
      else "×"
      end
    end
  end

  def base_fee(departure_station:, arrival_station:)
    start_order = [departure_station.station_order, arrival_station.station_order].min
    end_order   = [departure_station.station_order, arrival_station.station_order].max

    run_type.sections
      .joins(:from_station, :to_station)
      .where(stations: { station_order: start_order...end_order })
      .sum(:fee)
  end

  def fee_per_seat(
    departure_station:,
    arrival_station:,
    car_type:
  )
    base_fee(
      departure_station: departure_station,
      arrival_station: arrival_station
    ) + car_type.extra_fee
  end
end

class Run < ApplicationRecord
  belongs_to :run_type
  has_many :cars
  has_many :reservations, dependent: :destroy

  def display_name
    "#{run_type.name} #{run_number}号"
  end
  
  def first_station
    is_up ?
      Station.find_by!(station_name: "新大阪") :
      Station.find_by!(station_name: "東京")
  end

  # ★ その日の始発駅出発時刻を正しく作る
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

    def availability_mark(car_type_name, count)
    case car_type_name
    when "fabulous"
      case count
      when 5..6 then "◎"
      when 3..4 then "◯"
      when 1..2 then "△ (残り#{count})"
      else "×"
      end
    else # reserved / green
      case count
      when 20.. then "◎"
      when 7..19 then "◯"
      when 1..6 then "△ (残り#{count})"
      else "×"
      end
    end
  end

end

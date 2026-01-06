class Run < ApplicationRecord
  belongs_to :run_type
  has_many :cars
  has_many :reservations, dependent: :destroy


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

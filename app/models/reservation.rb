class Reservation < ApplicationRecord
  belongs_to :user
  belongs_to :run
  belongs_to :departure_station, class_name: "Station"
  belongs_to :arrival_station,   class_name: "Station"
end

class Station < ApplicationRecord
  has_many :from_sections, class_name: "Section", foreign_key: :from_station_id
  has_many :to_sections,   class_name: "Section", foreign_key: :to_station_id

  has_many :departure_reservations, class_name: "Reservation", foreign_key: :departure_station_id
  has_many :arrival_reservations, class_name: "Reservation", foreign_key: :arrival_station_id
end

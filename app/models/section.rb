class Section < ApplicationRecord
  belongs_to :run_type
  belongs_to :from_station, class_name: "Station"
  belongs_to :to_station, class_name: "Station"
end

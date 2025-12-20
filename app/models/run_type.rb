class RunType < ApplicationRecord
  has_many :runs
  has_many :sections

  def required_travel_time(from_station:, to_station:)

    return 0 if from_station.id == to_station.id

    start_order = [from_station.station_order, to_station.station_order].min
    end_order   = [from_station.station_order, to_station.station_order].max

    start_section = sections
      .joins(:from_station)
      .find_by!(stations: { station_order: start_order })

    end_section = sections
      .joins(:to_station)
      .find_by!(stations: { station_order: end_order })

    sections
      .where(section_order: start_section.section_order..end_section.section_order)
      .sum(:required_time)
  end
end

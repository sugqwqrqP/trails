Car.includes(:car_type).find_each do |car|
  case car.car_type.name

  when "fabulous"
    (1..6).each do |room_no|
      Seat.create!(
        car: car,
        row: room_no,
        column: "ROOM"
      )
    end

  when "reserved"
    rows = (1..8)
    cols = %w[A B C D E]

    rows.each do |row|
      cols.each do |col|
        Seat.create!(
          car: car,
          row: row,
          column: col
        )
      end
    end

  when "green"
    rows = (1..8)
    cols = %w[A B C D]

    rows.each do |row|
      cols.each do |col|
        Seat.create!(
          car: car,
          row: row,
          column: col
        )
      end
    end
  end
end

# db/seeds/reservations.rb

srand(1234)

excluded_runs = {
  "こだま" => [710, 713],
  "のぞみ" => [24]
}

def excluded_run?(run, excluded_runs)
  numbers = excluded_runs[run.run_type.name] || []
  numbers.include?(run.run_number)
end

def stations_for(run_type)
  stations = run_type.sections.flat_map { |s| [s.from_station, s.to_station] }
  stations.uniq.sort_by(&:station_order)
end

def pick_segment(stations, is_up)
  list = is_up ? stations.reverse : stations
  return [list.first, list.last] if list.size < 2

  from_index = rand(0..list.size - 2)
  to_index = rand(from_index + 1..list.size - 1)
  [list[from_index], list[to_index]]
end

def full_route_segment(stations, is_up)
  list = is_up ? stations.reverse : stations
  [list.first, list.last]
end

def available_seats_for(car, run, departure_station, arrival_station)
  car.seats.select do |seat|
    seat.available_for?(
      run: run,
      departure_station: departure_station,
      arrival_station: arrival_station
    )
  end
end

def create_reservation!(user, run, departure_station, arrival_station, seats)
  reservation = Reservation.create!(
    user: user,
    run: run,
    departure_station: departure_station,
    arrival_station: arrival_station,
    holder_name: user.user_fullname,
    is_issued: [true, false].sample
  )

  seats.each do |seat|
    ReservationSeat.create!(reservation: reservation, seat: seat)
  end
end

def reserve_seats!(run, seats, departure_station, arrival_station, users)
  seats.group_by(&:car).each do |car, car_seats|
    chunk_size = car.car_type.name == "fabulous" ? 1 : 3
    car_seats.each_slice(chunk_size) do |chunk|
      user = users.sample
      create_reservation!(user, run, departure_station, arrival_station, chunk)
    end
  end
end

def fill_car_type!(
  run,
  car_type_name,
  departure_station,
  arrival_station,
  desired_available,
  users
)
  cars = run.cars.select { |car| car.car_type.name == car_type_name }
  seats = cars.flat_map { |car| available_seats_for(car, run, departure_station, arrival_station) }
  return if seats.empty?

  reserve_count = [seats.size - desired_available, 0].max
  seats_to_reserve = seats.sample([reserve_count, seats.size].min)
  reserve_seats!(run, seats_to_reserve, departure_station, arrival_station, users)
end

eligible_users = User.where(role: 0)
  .where.not("login_id LIKE ?", "senshu_%")
  .to_a

runs = Run.includes(:run_type, cars: [:seats, :car_type])
  .where(run_on: Date.today..Date.today + 2)

run_type_stations = {}

runs.each do |run|
  next if excluded_run?(run, excluded_runs)
  next if eligible_users.empty?

  stations = run_type_stations[run.run_type_id] ||= stations_for(run.run_type)
  next if stations.size < 2

  day_offset = (run.run_on - Date.today).to_i
  hour = run.first_station_departure_time.strftime("%H").to_i

  departure_station, arrival_station = full_route_segment(stations, run.is_up)

  if day_offset.zero? && (11..14).include?(hour)
    # 昼のピークはほぼ満席（×や△が多め）
    fill_car_type!(
      run,
      "fabulous",
      departure_station,
      arrival_station,
      rand < 0.7 ? 0 : 1,
      eligible_users
    )
    fill_car_type!(
      run,
      "reserved",
      departure_station,
      arrival_station,
      rand < 0.6 ? 0 : rand(1..2),
      eligible_users
    )
    fill_car_type!(
      run,
      "green",
      departure_station,
      arrival_station,
      rand < 0.6 ? 0 : rand(1..2),
      eligible_users
    )
    next
  end

  if day_offset.zero? && (15..20).include?(hour)
    # 夕方は△が出る程度に調整（まばら）
    if rand < 0.7
      fill_car_type!(
        run,
        "fabulous",
        departure_station,
        arrival_station,
        rand(1..2),
        eligible_users
      )
      fill_car_type!(
        run,
        "reserved",
        departure_station,
        arrival_station,
        rand(1..6),
        eligible_users
      )
      fill_car_type!(
        run,
        "green",
        departure_station,
        arrival_station,
        rand(1..6),
        eligible_users
      )
    end
  end

  # それ以外は軽めにランダム予約
  reservation_count =
    if day_offset.zero?
      rand(2..5)
    else
      rand(1..2)
    end

  reservation_count.times do
    user = eligible_users.sample
    segment_departure, segment_arrival = pick_segment(stations, run.is_up)

    car = run.cars.sample
    next unless car

    seat_count = car.car_type.name == "fabulous" ? 1 : rand(1..3)
    available_seats = available_seats_for(
      car,
      run,
      segment_departure,
      segment_arrival
    )
    next if available_seats.size < seat_count
    seats = available_seats.sample(seat_count)

    create_reservation!(
      user,
      run,
      segment_departure,
      segment_arrival,
      seats
    )
  end
end

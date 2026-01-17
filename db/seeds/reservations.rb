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
  .order(:run_on, :run_number, :is_up)

run_type_stations = {}

def build_mark_plan(size)
  marks = [:high, :mid, :low, :zero]
  base = size / marks.size
  remainder = size % marks.size

  plan = marks.flat_map { |mark| [mark] * base }
  plan.concat(marks.sample(remainder))
  plan.shuffle
end

def target_available_count_for_mark(mark, car_type_name, total_seats)
  return 0 if total_seats <= 0

  if car_type_name == "fabulous"
    case mark
    when :high then rand(5..6)
    when :mid then rand(3..4)
    when :low then rand(1..2)
    else 0
    end
  else
    case mark
    when :high
      min = [50, total_seats].min
      max = total_seats
      min > max ? max : rand(min..max)
    when :mid
      min = [20, total_seats].min
      max = [49, total_seats].min
      min > max ? max : rand(min..max)
    when :low
      min = [1, total_seats].min
      max = [19, total_seats].min
      max < 1 ? 0 : (min > max ? max : rand(min..max))
    else
      0
    end
  end
end

# こだま713（東京→新大阪）の指定席 2号車 1A/1B/1C を3日分手動で予約
(0..2).each do |day_offset|
  manual_run = runs.find do |run|
    run.run_on == Date.today + day_offset &&
      run.run_type.name == "こだま" &&
      run.run_number == 713 &&
      run.is_up == false
  end

  next unless manual_run && eligible_users.any?

  manual_departure = Station.find_by!(station_name: "東京")
  manual_arrival = Station.find_by!(station_name: "新大阪")
  manual_user = User.find_by(login_id: "test_taro") || eligible_users.sample
  manual_car = manual_run.cars.find { |car| car.number == 2 && car.car_type.name == "reserved" }

  next unless manual_car

  manual_seats = %w[A B C].map do |col|
    manual_car.seats.find_by(row: 1, column: col)
  end.compact

  next unless manual_seats.size == 3

  available = manual_seats.all? do |seat|
    seat.available_for?(
      run: manual_run,
      departure_station: manual_departure,
      arrival_station: manual_arrival
    )
  end

  next unless available

  create_reservation!(
    manual_user,
    manual_run,
    manual_departure,
    manual_arrival,
    manual_seats
  )
end

eligible_runs = runs.reject { |run| excluded_run?(run, excluded_runs) }
return if eligible_users.empty?

mark_plans = {
  "reserved" => build_mark_plan(eligible_runs.size),
  "green" => build_mark_plan(eligible_runs.size),
  "fabulous" => build_mark_plan(eligible_runs.size)
}

eligible_runs.each_with_index do |run, index|
  stations = run_type_stations[run.run_type_id] ||= stations_for(run.run_type)
  next if stations.size < 2

  departure_station, arrival_station = full_route_segment(stations, run.is_up)

  %w[reserved green fabulous].each do |car_type|
    total_seats =
      run.cars
        .select { |car| car.car_type.name == car_type }
        .sum { |car| car.seats.size }

    desired_available = target_available_count_for_mark(
      mark_plans[car_type][index],
      car_type,
      total_seats
    )

    fill_car_type!(
      run,
      car_type,
      departure_station,
      arrival_station,
      desired_available,
      eligible_users
    )
  end
end

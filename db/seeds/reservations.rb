# db/seeds/reservations.rb

tokyo = Station.find_by!(station_name: "東京")
shin_osaka = Station.find_by!(station_name: "新大阪")
shizuoka = Station.find_by!(station_name: "静岡")

test_taro = User.find_by!(login_id: "test_taro")
seed_users = User.where(role: :user)
  .where.not(login_id: ["test_user1", "test_taro"])
  .where.not("login_id LIKE ?", "senshu_%")
  .limit(12)
  .to_a

def create_demo_reservation!(user:, run:, departure_station:, arrival_station:, seats:, issued: false)
  reservation = Reservation.create!(
    user: user,
    run: run,
    departure_station: departure_station,
    arrival_station: arrival_station,
    holder_name: user.user_fullname,
    is_issued: issued
  )

  seats.each do |seat|
    ReservationSeat.create!(reservation: reservation, seat: seat)
  end
end

def demo_run!(run_type_name:, run_number:, run_on:, is_up: false)
  Run.joins(:run_type).find_by!(
    run_types: { name: run_type_name },
    run_number: run_number,
    run_on: run_on,
    is_up: is_up
  )
end

def seats_for(run:, car_type_name:)
  run.cars
    .includes(:car_type, :seats)
    .select { |car| car.car_type.name == car_type_name }
    .flat_map { |car| car.seats.sort_by { |seat| [car.number, seat.row, seat.column] } }
end

def reserve_demo_seats!(
  run:,
  car_type_name:,
  departure_station:,
  arrival_station:,
  reserve_count:,
  users:
)
  index = 0
  seats_for(run: run, car_type_name: car_type_name)
    .first(reserve_count)
    .group_by(&:car)
    .each_value do |car_seats|
      car_seats.each_slice(car_type_name == "fabulous" ? 1 : 3) do |seats|
        create_demo_reservation!(
          user: users[index % users.size],
          run: run,
          departure_station: departure_station,
          arrival_station: arrival_station,
          seats: seats,
          issued: index.even?
        )
        index += 1
      end
    end
end

return if seed_users.empty?

today = Date.today

# 指定席を満席にし、検索結果で「×」を確認できる便
full_reserved_run = demo_run!(
  run_type_name: "のぞみ",
  run_number: 1,
  run_on: today
)
reserve_demo_seats!(
  run: full_reserved_run,
  car_type_name: "reserved",
  departure_station: tokyo,
  arrival_station: shin_osaka,
  reserve_count: seats_for(run: full_reserved_run, car_type_name: "reserved").size,
  users: seed_users
)

# 残席少・満席・空席ありの表示をまとめて確認できる便
mixed_availability_run = demo_run!(
  run_type_name: "ひかり",
  run_number: 503,
  run_on: today
)
reserve_demo_seats!(
  run: mixed_availability_run,
  car_type_name: "reserved",
  departure_station: tokyo,
  arrival_station: shin_osaka,
  reserve_count: seats_for(run: mixed_availability_run, car_type_name: "reserved").size - 19,
  users: seed_users
)
reserve_demo_seats!(
  run: mixed_availability_run,
  car_type_name: "green",
  departure_station: tokyo,
  arrival_station: shin_osaka,
  reserve_count: seats_for(run: mixed_availability_run, car_type_name: "green").size,
  users: seed_users
)
reserve_demo_seats!(
  run: mixed_availability_run,
  car_type_name: "fabulous",
  departure_station: tokyo,
  arrival_station: shin_osaka,
  reserve_count: 4,
  users: seed_users
)

# 同一座席でも区間が重ならない場合は予約できることを確認しやすい便
segment_demo_run = demo_run!(
  run_type_name: "こだま",
  run_number: 703,
  run_on: today
)
demo_car = segment_demo_run.cars.find_by!(number: 2)
demo_seats = %w[A B C].map { |column| demo_car.seats.find_by!(row: 1, column: column) }

create_demo_reservation!(
  user: test_taro,
  run: segment_demo_run,
  departure_station: tokyo,
  arrival_station: shizuoka,
  seats: demo_seats,
  issued: false
)

create_demo_reservation!(
  user: seed_users.first,
  run: segment_demo_run,
  departure_station: shizuoka,
  arrival_station: shin_osaka,
  seats: demo_seats,
  issued: true
)

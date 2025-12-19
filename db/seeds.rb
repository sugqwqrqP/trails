# db/seeds.rb
Run.create!(
  name: "のぞみ1号",
  run_number: 1,
  run_on: Date.new(2025, 12, 25),
  is_up: false,
  departure_station_name: "東京",
  arrival_station_name: "新大阪",
  departure_time: "09:00",
  arrival_time: "12:00"
)

Run.create!(
  name: "のぞみ3号",
  run_number: 3,
  run_on: Date.new(2025, 12, 25),
  is_up: false,
  departure_station_name: "東京",
  arrival_station_name: "新大阪",
  departure_time: "10:00",
  arrival_time: "13:00"
)

Run.create!(
  name: "ひかり101号",
  run_number: 101,
  run_on: Date.new(2025, 12, 25),
  is_up: false,
  departure_station_name: "東京",
  arrival_station_name: "新大阪",
  departure_time: "10:10",
  arrival_time: "13:30"
)

User.create!(
  login_id: "test_taro",
  user_fullname: "テスト太郎",
  password: "Abc123!",
  password_confirmation: "Abc123!",
  role: 0
)

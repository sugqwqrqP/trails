
nozomi = RunType.find_by!(name: "のぞみ")
hikari = RunType.find_by!(name: "ひかり")

Run.create!(
  name: "のぞみ1号",
  run_type: nozomi,
  run_number: 1,
  run_on: Date.new(2025, 12, 25),
  is_up: false, # 下り
  departure_time: "09:00",
  arrival_time: "12:00"
)

Run.create!(
  name: "のぞみ3号",
  run_type: nozomi,
  run_number: 3,
  run_on: Date.new(2025, 12, 25),
  is_up: false,
  departure_time: "10:00",
  arrival_time: "13:00"
)

Run.create!(
  name: "ひかり101号",
  run_type: hikari,
  run_number: 101,
  run_on: Date.new(2025, 12, 25),
  is_up: false,
  departure_time: "10:10",
  arrival_time: "13:30"
)

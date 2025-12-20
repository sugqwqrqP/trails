# db/seeds/runs.rb

tokyo      = Station.find_by!(station_name: "東京")
shin_osaka = Station.find_by!(station_name: "新大阪")

nozomi  = RunType.find_by!(name: "のぞみ")
hikari  = RunType.find_by!(name: "ひかり")
kodama  = RunType.find_by!(name: "こだま")

schedule = [
  ["07:00", nozomi],
  ["08:00", nozomi],
  ["09:00", nozomi],
  ["10:00", nozomi],
  ["10:30", kodama],
  ["11:00", nozomi],
  ["11:30", hikari],
  ["12:00", nozomi],
  ["12:30", kodama],
  ["13:00", nozomi],
  ["13:30", hikari],
  ["14:00", nozomi],
  ["14:30", kodama],
  ["15:00", nozomi],
  ["15:30", hikari],
  ["16:00", nozomi],
  ["16:30", kodama],
  ["17:00", nozomi],
  ["17:30", hikari],
  ["18:00", nozomi],
  ["18:30", kodama],
  ["19:00", nozomi],
  ["19:30", hikari],
  ["20:00", nozomi],
  ["20:30", kodama],
  ["21:00", nozomi],
  ["21:30", hikari],
  ["22:00", nozomi],
]

base_numbers = {
  "のぞみ" => 1,
  "ひかり" => 501,
  "こだま" => 701
}

(0..2).each do |day_offset|
  run_on = Date.today + day_offset

  # 東京 → 新大阪（下り・奇数）
  counters_down = base_numbers.transform_values { |v| v }

  schedule.each do |time_str, run_type|
    Run.create!(
      name: "#{run_type.name} #{counters_down[run_type.name]}号",
      run_number: counters_down[run_type.name],
      run_on: run_on,
      is_up: false,
      first_station_departure_time: time_str,
      run_type: run_type
    )
    counters_down[run_type.name] += 2
  end

  # 新大阪 → 東京（上り・偶数）
  counters_up = base_numbers.transform_values { |v| v + 1 }

  schedule.each do |time_str, run_type|
    Run.create!(
      name: "#{run_type.name} #{counters_up[run_type.name]}号",
      run_number: counters_up[run_type.name],
      run_on: run_on,
      is_up: true,
      first_station_departure_time: time_str,
      run_type: run_type
    )
    counters_up[run_type.name] += 2
  end
end

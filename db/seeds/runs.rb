# db/seeds/runs.rb

tokyo      = Station.find_by!(station_name: "東京")
shin_osaka = Station.find_by!(station_name: "新大阪")

nozomi  = RunType.find_by!(name: "のぞみ")
hikari  = RunType.find_by!(name: "ひかり")
kodama  = RunType.find_by!(name: "こだま")

schedule = [
  ["06:00", nozomi],
  ["07:30", hikari],
  ["09:00", nozomi],
  ["10:30", kodama],
  ["12:00", nozomi],
  ["14:30", kodama],
  ["15:30", hikari],
  ["18:30", kodama],
]

base_numbers = {
  "のぞみ" => 1,
  "ひかり" => 501,
  "こだま" => 701
}

demo_start_on = Date.new(2028, 5, 1)
demo_end_on = Date.new(2028, 5, 14)

# デモ環境で日付切れしないよう、2028年5月前半の便を固定で投入
(demo_start_on..demo_end_on).each do |run_on|

  # 東京 → 新大阪（下り・奇数）
  counters_down = base_numbers.transform_values { |v| v }

  schedule.each do |time_str, run_type|
    Run.create!(
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
      run_number: counters_up[run_type.name],
      run_on: run_on,
      is_up: true,
      first_station_departure_time: time_str,
      run_type: run_type
    )
    counters_up[run_type.name] += 2
  end
end

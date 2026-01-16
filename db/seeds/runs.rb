# db/seeds/runs.rb

tokyo      = Station.find_by!(station_name: "東京")
shin_osaka = Station.find_by!(station_name: "新大阪")

nozomi  = RunType.find_by!(name: "のぞみ")
hikari  = RunType.find_by!(name: "ひかり")
kodama  = RunType.find_by!(name: "こだま")

schedule = [
  ["06:00", nozomi],
  ["06:30", kodama],
  ["07:00", nozomi],
  ["07:30", hikari],
  ["08:00", nozomi],
  ["08:30", kodama],
  ["09:00", nozomi],
  ["09:30", hikari],
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
  ["21:00", nozomi]
]

base_numbers = {
  "のぞみ" => 1,
  "ひかり" => 501,
  "こだま" => 701
}

# 4日目以降に流すこだまだけの最低限ダイヤ
limited_schedule = [
  ["06:30", kodama]
]

# 0日目〜15日目を投入
days = 16
(0...days).each do |day_offset|
  run_on = Date.today + day_offset

  if day_offset <= 3
    # 0〜3日目はフル便ダイヤ
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
  else
    # 4日目以降はこだまのみ（上下1本）
    limited_schedule.each do |time_str, run_type|
      Run.create!(
        run_number: base_numbers[run_type.name],
        run_on: run_on,
        is_up: false,
        first_station_departure_time: time_str,
        run_type: run_type
      )

      # 上りは偶数便
      Run.create!(
        run_number: base_numbers[run_type.name] + 1,
        run_on: run_on,
        is_up: true,
        first_station_departure_time: time_str,
        run_type: run_type
      )
    end
  end
end

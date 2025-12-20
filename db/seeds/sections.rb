# db/seeds/sections.rb

# === RunType を取得 ===
run_types = {
  nozomi: RunType.find_by!(name: "のぞみ"),
  hikari: RunType.find_by!(name: "ひかり"),
  kodama: RunType.find_by!(name: "こだま")
}

# === 停車駅定義===
stations_by_type = {
  nozomi: %w[東京 品川 新横浜 名古屋 京都 新大阪],
  hikari: %w[東京 品川 新横浜 静岡 浜松 名古屋 京都 新大阪],
  kodama: %w[東京 品川 新横浜 小田原 熱海 三島 新富士 静岡 掛川 浜松 豊橋 三河安城 名古屋 岐阜羽島 米原 京都 新大阪]
}

# === Station を名前→オブジェクトで引けるようにする ===
station_map = Station.all.index_by(&:station_name)

# === 区間ごとの所要時間・料金 ===
section_data = {
  nozomi: {
    ["東京", "品川"]     => { time: 6,  fee: 500 },
    ["品川", "新横浜"]   => { time: 11, fee: 1200 },
    ["新横浜", "名古屋"] => { time: 82, fee: 7000 },
    ["名古屋", "京都"]   => { time: 34, fee: 2500 },
    ["京都", "新大阪"]   => { time: 14, fee: 1500 }
  },
  hikari: {
    ["東京", "品川"]     => { time: 6,  fee: 400 },
    ["品川", "新横浜"]   => { time: 11, fee: 600 },
    ["新横浜", "静岡"]   => { time: 42, fee: 3000 },
    ["静岡", "浜松"]     => { time: 20, fee: 1500 },
    ["浜松", "名古屋"]   => { time: 30, fee: 2000 },
    ["名古屋", "京都"]   => { time: 34, fee: 2000 },
    ["京都", "新大阪"]   => { time: 14, fee: 1000 }
  },
  kodama: {
    ["東京", "品川"]       => { time: 6,  fee: 300 },
    ["品川", "新横浜"]     => { time: 11, fee: 400 },
    ["新横浜", "小田原"]   => { time: 15, fee: 800 },
    ["小田原", "熱海"]     => { time: 12, fee: 600 },
    ["熱海", "三島"]       => { time: 8, fee: 400 },
    ["三島", "新富士"]     => { time: 13, fee: 500 },
    ["新富士", "静岡"]     => { time: 15, fee: 700 },
    ["静岡", "掛川"]       => { time: 16, fee: 900 },
    ["掛川", "浜松"]       => { time: 12, fee: 600 },
    ["浜松", "豊橋"]       => { time: 16, fee: 1200 },
    ["豊橋", "三河安城"]   => { time: 19, fee: 500 },
    ["三河安城", "名古屋"] => { time: 16, fee: 400 },
    ["名古屋", "岐阜羽島"] => { time: 16, fee: 500 },
    ["岐阜羽島", "米原"]   => { time: 17, fee: 700 },
    ["米原", "京都"]       => { time: 24, fee: 1200 },
    ["京都", "新大阪"]     => { time: 17, fee: 800 }
  }
}

# === Section 作成 ===
stations_by_type.each do |type, station_names|
  station_names.each_cons(2).with_index(1) do |(from, to), order|
    data = section_data.dig(type, [from, to])

    Section.create!(
      run_type: run_types[type],
      from_station: station_map.fetch(from),
      to_station: station_map.fetch(to),
      section_order: order,
      required_time: data[:time],
      fee: data[:fee]
    )
  end
end


# 主キーが1,2,3のRunTypeオブジェクトを持ってくる
# オブジェクトを入れても、belongs_toで関連付けされてれば、結局参照先の主キーに変換して保存されるのでOK

nozomi = RunType.find(1)
hikari = RunType.find(2)
kodama = RunType.find(3)

tokyo      = Station.find_by!(station_name: "東京")
shinagawa  = Station.find_by!(station_name: "品川")
shinyoko   = Station.find_by!(station_name: "新横浜")

Section.create!(
  run_type: nozomi,
  from_station: tokyo,
  to_station: shinagawa,
  section_order: 1,
  required_time: 6,
  fee: 500
)

Section.create!(
  run_type: nozomi,
  from_station: shinagawa,
  to_station: shinyoko,
  section_order: 2,
  required_time: 12,
  fee: 800
)

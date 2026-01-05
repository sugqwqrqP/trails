fabulous = CarType.find_by!(name: "fabulous")
reserved = CarType.find_by!(name: "reserved")
green    = CarType.find_by!(name: "green")

Run.find_each do |run|
  # 1号車：ファビュラス
  Car.create!(
    run: run,
    car_type: fabulous,
    number: 1
  )

  # 2,3,6,7,8号車：指定席
  [2, 3, 6, 7, 8].each do |no|
    Car.create!(
      run: run,
      car_type: reserved,
      number: no
    )
  end

  # 4,5号車：グリーン
  [4, 5].each do |no|
    Car.create!(
      run: run,
      car_type: green,
      number: no
    )
  end
end

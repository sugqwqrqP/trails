# db/seeds.rb

# db:seed / db:rebuild 実行時に以下の seed を順に読み込む

load Rails.root.join("db/seeds/stations.rb")
load Rails.root.join("db/seeds/run_types.rb")
load Rails.root.join("db/seeds/car_types.rb")
load Rails.root.join("db/seeds/sections.rb")
load Rails.root.join("db/seeds/users.rb")
load Rails.root.join("db/seeds/runs.rb")
load Rails.root.join("db/seeds/cars.rb")
load Rails.root.join("db/seeds/seats.rb")
load Rails.root.join("db/seeds/reservations.rb")

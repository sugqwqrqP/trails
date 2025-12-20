# db/seeds.rb

# db:seed / db:rebuild 実行時に以下の seed を順に読み込む

load Rails.root.join("db/seeds/stations.rb")
load Rails.root.join("db/seeds/users.rb")
load Rails.root.join("db/seeds/runs.rb")

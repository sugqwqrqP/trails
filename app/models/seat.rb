class Seat < ApplicationRecord
  has_many :reservation_seats
  has_many :reservations, through: :reservation_seats

  belongs_to :car

  def available_for?(run:, departure_station:, arrival_station:)
  # 検索区間の駅順を正規化する
  # 上り・下りどちらでも比較できるように、station_order の小さい方を from_o、大きい方を to_o に揃える
  from_o, to_o = [
    departure_station.station_order,
    arrival_station.station_order
  ].minmax

  reservations
    .where(run: run)
    .none? do |r|
      # 既存予約の区間も同様に正規化
      r_from, r_to = [
        r.departure_station.station_order,
        r.arrival_station.station_order
      ].minmax

      # 区間の重なり判定
      # [from_o, to_o) と [r_from, r_to) が重なっていたら予約不可
      # 重なり条件：
      # 自分の出発 < 相手の到着 かつ 相手の出発 < 自分の到着
      # 到着駅 = 出発駅 の境界は「重ならない」とみなす
      from_o < r_to && r_from < to_o
    end
  end
end

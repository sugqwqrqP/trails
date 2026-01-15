class CarType < ApplicationRecord
  has_many :cars

  def label
    case name
    when "reserved"  then "指定席"
    when "green"     then "グリーン車"
    when "fabulous"  then "ファビュラス"
    else name
    end
  end

  def extra_fee
    case name
    when "reserved" then 0
    when "green"    then 5000
    when "fabulous" then 20000
    end
  end
end

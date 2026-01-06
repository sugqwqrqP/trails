class CarType < ApplicationRecord
  has_many :cars

  def extra_fee
    case name
    when "reserved" then 0
    when "green"    then 5000
    when "fabulous" then 20000
    end
  end
end

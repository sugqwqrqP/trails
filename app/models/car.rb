class Car < ApplicationRecord
  belongs_to :run
  belongs_to :car_type
  has_many :seats
end

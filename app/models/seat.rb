class Seat < ApplicationRecord
  has_many :reservation_seats
  has_many :reservations, through: :reservation_seats
  
  belongs_to :car
end

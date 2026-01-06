class ReservationSeat < ApplicationRecord
  belongs_to :reservation
  belongs_to :seat
end

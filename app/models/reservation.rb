class Reservation < ApplicationRecord
  has_many :reservation_seats, dependent: :destroy
  has_many :seats, through: :reservation_seats

  belongs_to :user
  belongs_to :run
  belongs_to :departure_station, class_name: "Station"
  belongs_to :arrival_station,   class_name: "Station"

  validates :holder_name,
    presence: { message: "予約者名義を入力してください" },
    length: {
      maximum: 20,
      message: "予約者名義は20文字以内で入力してください"
    }

end

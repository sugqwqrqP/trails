class Run < ApplicationRecord
  belongs_to :run_type
  has_many :cars
  has_many :reservations, dependent: :destroy
end

class Run < ApplicationRecord
  belongs_to :run_type
  has_many :cars
end

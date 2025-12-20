class RunType < ApplicationRecord
  has_many :runs
  has_many :sections
end

class TreasureFind < ApplicationRecord
  belongs_to :user
  belongs_to :treasure
  belongs_to :server
end

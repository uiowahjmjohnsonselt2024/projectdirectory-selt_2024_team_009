class TreasureFind < ApplicationRecord
  belongs_to :user
  belongs_to :treasure
  belongs_to :server
  belongs_to :game

  validates :found_at, presence: true
end

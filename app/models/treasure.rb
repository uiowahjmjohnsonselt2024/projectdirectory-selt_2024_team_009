class Treasure < ApplicationRecord
  belongs_to :item
  has_many :grid_cells
  validates :name, presence: true
  validates :description, presence: true
end

class Treasure < ApplicationRecord
  belongs_to :item
  belongs_to :game
  belongs_to :grid_cell, optional: true
  belongs_to :owner, class_name: 'ServerUser', optional: true
  validates :name, presence: true
  validates :description, presence: true
end

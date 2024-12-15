class Item < ApplicationRecord
  has_many :server_user_items, dependent: :destroy
  validates :name, presence: true
  validates :description, presence: true
  validates :price, numericality: { greater_than: 0 }
end

class Inventory < ApplicationRecord
  belongs_to :user
  belongs_to :item
  validates :quantity, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true

end

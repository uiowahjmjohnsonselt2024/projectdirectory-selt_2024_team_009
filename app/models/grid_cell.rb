class GridCell < ApplicationRecord
  belongs_to :server
  belongs_to :content, optional: true
  belongs_to :treasure, optional: true
  belongs_to :owner, class_name: 'ServerUser', optional: true

  # Validations
  validates :x, :y, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than: 6 }

  def occupied?
    owner.present?
  end
  # Check if cell is fortified
  def fortified?
    fortified.present? && fortified > 0
  end
  def obstacle?
    !!obstacle
  end
end

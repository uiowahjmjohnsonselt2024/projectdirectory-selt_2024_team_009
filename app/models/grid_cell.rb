class GridCell < ApplicationRecord
  belongs_to :server
  belongs_to :content, optional: true
  belongs_to :treasure, optional: true
  belongs_to :owner, class_name: 'ServerUser', optional: true

  # Validations
  validates :x, :y, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than: 6 }

  # Check if the cell is occupied
  def occupied?
    owner.present? || obstacle?
  end

  # Check if the cell is fortified
  def fortified?
    fortified.present? && fortified > 0
  end

  # Check if the cell is an obstacle
  def obstacle?
    !!obstacle
  end

  # Retrieve the shared background image URL from the server
  def background_image_url
    server.background_image_url
  end
end

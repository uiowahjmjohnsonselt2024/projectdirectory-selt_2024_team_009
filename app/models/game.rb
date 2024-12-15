class Game < ApplicationRecord
  belongs_to :server
  has_many :messages, dependent: :destroy
  # REMOVED: has_many :server_users (Incorrect association)
  has_many :users, through: :server_users # Correct association through server
  has_many :server_users, through: :server
  has_many :treasures, dependent: :destroy  # Now treasures belong to game

  # Validations
  validates :name, presence: true
  before_validation :set_default_name, on: :create
  def server_user(user)
    server.server_users.find_by(user: user)
  end
  def waiting_for_players
    server.server_users.count < server.max_players
  end
  def winner
    server.server_users.max_by { |su| server.grid_cells.where(owner: su).count }
  end

  private

  def set_default_name
    self.name ||= "Game-#{self.server_id}-#{Time.now.to_i}"
  end
end
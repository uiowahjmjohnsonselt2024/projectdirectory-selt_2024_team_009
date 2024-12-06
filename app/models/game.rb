class Game < ApplicationRecord
  # Associations
  has_many :messages, dependent: :destroy
  has_many :server_users, dependent: :destroy
  has_many :users, through: :server_users

  # Validations
  validates :name, presence: true, uniqueness: true
end

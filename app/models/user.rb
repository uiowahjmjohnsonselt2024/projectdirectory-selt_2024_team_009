class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Associations
  has_one :wallet, dependent: :destroy
  has_many :created_servers, class_name: 'Server', foreign_key: 'created_by', dependent: :destroy
  has_many :server_users, dependent: :destroy
  has_many :servers, through: :server_users

  has_many :transactions, dependent: :destroy
  has_many :inventories, dependent: :destroy
  has_many :items, through: :inventories
  has_many :scores, dependent: :destroy
  has_many :treasure_finds, dependent: :destroy
  has_many :leaderboard_entries, dependent: :destroy
  has_many :leaderboards, through: :leaderboard_entries

  # Validations
  validates :username, presence: true, uniqueness: true
  validates :email, presence: true, uniqueness: true
  validates :role, presence: true, inclusion: { in: %w[admin player], message: "%{value} is not a valid role" }
  validates :cable_token, uniqueness: true, allow_nil: true # Key change: allow_nil

  # Callbacks
  before_validation :ensure_cable_token # Key change: before_validation and new method
  after_create :create_wallet_with_initial_balance


  # Role Methods
  def admin?
    role == 'admin'
  end

  def player?
    role == 'player'
  end

  private

  def create_wallet_with_initial_balance
    Wallet.create(user: self, balance: 500)
  end

  def ensure_cable_token # New method to handle token generation
    if cable_token.nil?
      self.cable_token = loop do
        token = SecureRandom.hex(16) # Use hex as before
        break token unless User.exists?(cable_token: token)
      end
    end
  end
end
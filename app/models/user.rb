class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  # Devise modules for authentication
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Associations
  has_one :wallet, dependent: :destroy
  # Add association for servers the user created
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
  validates :cable_token, presence: true, uniqueness: true

  before_create :generate_cable_token
  #Callbacks
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
  def generate_cable_token
    # Generate a unique cable_token
    begin
      self.cable_token = SecureRandom.hex(16)
    end while self.class.exists?(cable_token: cable_token)
  end
end
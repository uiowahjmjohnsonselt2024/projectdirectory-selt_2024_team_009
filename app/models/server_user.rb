class ServerUser < ApplicationRecord
  belongs_to :server
  belongs_to :user
  has_many :grid_cells, foreign_key: :owner_id
  has_many :treasures, foreign_key: :owner_id
  has_many :server_user_items, dependent: :destroy
  has_many :game_items, through: :server_user_items, source: :item

  #before_create :deduct_entry_fee
  # Validations
  validates :total_ap, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :turn_ap, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :shard_balance, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :symbol, inclusion: { in: %w[🟢 🔴 🔵 🟡 🟣 🟤] }, allow_nil: true
  validates :turn_order, numericality: { only_integer: true }, allow_nil: true
  validates :role, presence: true
  validates :user_id, presence: true
  validates :server_id, presence: true

  # Callbacks
  after_initialize :set_default_role, if: :new_record?
  after_initialize :set_defaults, if: :new_record?
  # Methods to manage AP and Shards
  def spend_turn_ap(amount)
    if turn_ap >= amount
      self.turn_ap -= amount
      self.total_ap -= amount
      save
    else
      errors.add(:base, 'Not enough turn AP')
      false
    end
  end

  def deduct_entry_fee
    if user.wallet.balance < 200
      raise InsufficientFundsError, "Not enough shards to join game"
    end
    user.wallet.deduct(200)
  end
  def spend_total_ap(amount)
    if total_ap >= amount
      self.total_ap -= amount
      save
    else
      errors.add(:base, 'Not enough total AP')
      false
    end
  end
  def choose_game_items(item_ids)
    # Ensure user owns these items in their global inventory
    # Check in the Inventory model
    user_items = user.inventories.where(item_id: item_ids)
    if user_items.size < item_ids.size
      errors.add(:base, "You don't own all of these items.")
      return false
    end

    if item_ids.size > 5
      errors.add(:base, "You can only bring up to 5 items into the game.")
      return false
    end

    # Create ServerUserItem records
    item_ids.each do |id|
      server_user_items.create!(item_id: id)
    end
    true
  end

  def adjust_shard_balance(amount)
    self.shard_balance += amount
    save
  end

  def reset_turn_ap
    self.turn_ap = 2
    save
  end

  # Decrement temporary effects counters
  def decrement_temporary_effects
    if diagonal_moves_left && diagonal_moves_left > 0
      self.diagonal_moves_left -= 1
      self.can_move_diagonally = false if diagonal_moves_left.zero?
    end

    if turns_skipped && turns_skipped > 0
      self.turns_skipped -= 1
    end

    save
  end

  private
  def set_default_role
    self.role ||= 'player'
  end
  def set_defaults
    self.total_ap ||= 200
    self.turn_ap ||= 2
    self.shard_balance ||= 0
  end
end
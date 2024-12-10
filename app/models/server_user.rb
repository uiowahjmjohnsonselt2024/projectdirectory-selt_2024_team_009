class ServerUser < ApplicationRecord
  belongs_to :server
  belongs_to :user
  has_many :grid_cells, foreign_key: :owner_id
  has_many :treasures, through: :grid_cells
  #before_create :deduct_entry_fee
  # Validations
  validates :total_ap, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :turn_ap, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :shard_balance, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :symbol, presence: true, allow_nil: true
  validates :turn_order, numericality: { only_integer: true }, allow_nil: true


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
end

class Transaction < ApplicationRecord
  belongs_to :user
  belongs_to :item

  validates :balance, numericality: { greater_than_or_equal_to: 0 }, presence: true

  # Either purchase or earn
  VALID_TRANSACTION_TYPES = %w[purchase earn]

  validates :transaction_type, inclusion: { 
    in: VALID_TRANSACTION_TYPES,
    message: "%{value} is not a valid transaction type"
  }  
end
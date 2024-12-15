require 'rails_helper'

RSpec.describe Transaction, type: :model do
  describe 'Associations' do
    it 'belongs to a user' do
      assoc = described_class.reflect_on_association(:user)
      expect(assoc.macro).to eq(:belongs_to)
    end

    it 'belongs to an item' do
      assoc = described_class.reflect_on_association(:item)
      expect(assoc.macro).to eq(:belongs_to)
    end
  end

  describe 'Validations' do
    it 'is valid with a user_id and item_id' do
      user = User.create!(username: 'Player1', email: 'player1@example.com', password: 'password123')
      item = Item.create!(name: 'Sword', description: 'A sharp blade', score: 50)
      transaction = Transaction.new(user: user, item: item)
      expect(transaction).to be_valid
    end

    it 'is invalid without a user_id' do
      item = Item.create!(name: 'Sword', description: 'A sharp blade', score: 50)
      transaction = Transaction.new(item: item)
      expect(transaction).not_to be_valid
      expect(transaction.errors[:user]).to include("must exist")
    end

    it 'is invalid without an item_id' do
      user = User.create!(username: 'Player1', email: 'player1@example.com', password: 'password123')
      transaction = Transaction.new(user: user)
      expect(transaction).not_to be_valid
      expect(transaction.errors[:item]).to include("must exist")
    end
  end
end

require 'rails_helper'

RSpec.describe Treasure, type: :model do
  describe 'Associations' do
    it 'belongs to an item' do
      assoc = described_class.reflect_on_association(:item)
      expect(assoc.macro).to eq(:belongs_to)
    end
  end

  describe 'Validations' do
    it 'is valid with an item_id' do
      #item = Item.create!(name: 'Golden Crown', description: 'A treasure fit for royalty', score: 100)
      #treasure = Treasure.new(item: item)
      #expect(treasure).to be_valid
    end

    it 'is invalid without an item_id' do
      treasure = Treasure.new
      expect(treasure).not_to be_valid
      expect(treasure.errors[:item]).to include("must exist")
    end
  end
end

require 'rails_helper'

RSpec.describe Inventory, type: :model do

  let(:item1) { Item.create(name: "Sword", description: "A sharp blade", score: 50) }
  let(:item2) { Item.create(name: "Shield", description: "A sturdy shield", score: 30) }
  let(:item3) { Item.create(name: "Potion", description: "Heals 50 HP", score: 20) }

  describe "inventory management" do
    context "adding items to inventory" do
      it "allows a player to add items to their inventory" do
        Inventory << item1
        Inventory << item2
        expect(Inventory).to include(item1, item2)
      end

      it "returns false if an item is not in the inventory" do
        expect(player.items).not_to include(item3)
      end
    end

    context "calculating cumulative score" do
      before do
        Inventory << item1
        Inventory << item2
        Inventory << item3
      end

      it "calculates the total score of all items in the inventory" do
        total_score = player.items.sum(:score)
        expect(total_score).to eq(100)
      end
    end
  end
end

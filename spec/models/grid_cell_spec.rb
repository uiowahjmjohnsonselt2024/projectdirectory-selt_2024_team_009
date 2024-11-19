require 'rails_helper'

RSpec.describe GridCell, type: :model do
    describe 'Associations' do
      it 'belongs to a server' do
        assoc = described_class.reflect_on_association(:server)
        expect(assoc.macro).to eq(:belongs_to)
      end

      it 'belongs to content' do
        assoc = described_class.reflect_on_association(:content)
        expect(assoc.macro).to eq(:belongs_to)
      end

      it 'belongs to a treasure' do
        assoc = described_class.reflect_on_association(:treasure)
        expect(assoc.macro).to eq(:belongs_to)
      end
    end

    describe 'Validations' do
      it 'is valid with server_id, content_id, and treasure_id' do
        server = Server.create!(name: 'Test Server')
        content = Content.create!(name: 'Grassland', description: 'A grassy area')
        treasure = Treasure.create!(item: Item.create!(name: 'Golden Chest', description: 'A valuable chest', score: 500))
        grid_cell = GridCell.new(server: server, content: content, treasure: treasure)
        expect(grid_cell).to be_valid
      end

      it 'is invalid without a server_id' do
        content = Content.create!(name: 'Grassland', description: 'A grassy area')
        treasure = Treasure.create!(item: Item.create!(name: 'Golden Chest', description: 'A valuable chest', score: 500))
        grid_cell = GridCell.new(content: content, treasure: treasure)
        expect(grid_cell).not_to be_valid
        expect(grid_cell.errors[:server]).to include("must exist")
      end

      it 'is invalid without a content_id' do
        server = Server.create!(name: 'Test Server')
        treasure = Treasure.create!(item: Item.create!(name: 'Golden Chest', description: 'A valuable chest', score: 500))
        grid_cell = GridCell.new(server: server, treasure: treasure)
        expect(grid_cell).not_to be_valid
        expect(grid_cell.errors[:content]).to include("must exist")
      end

      it 'is invalid without a treasure_id' do
        server = Server.create!(name: 'Test Server')
        content = Content.create!(name: 'Grassland', description: 'A grassy area')
        grid_cell = GridCell.new(server: server, content: content)
        expect(grid_cell).not_to be_valid
        expect(grid_cell.errors[:treasure]).to include("must exist")
      end
    end
end

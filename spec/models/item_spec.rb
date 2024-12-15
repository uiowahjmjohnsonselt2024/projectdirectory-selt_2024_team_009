require 'rails_helper'

RSpec.describe Item, type: :model do
  let(:valid_attributes) do
    {
      name: "Sample Item",
      description: "A brief description of the item.",
      score: 85
    }
  end

  context "validations" do
    it "is valid with a name, short description, and score" do
      pending("Score resolution @Jack")
      item = Item.new valid_attributes
      expect(item).to be_valid
    end

    it "is invalid without a name" do
      pending("Score resolution @Jack")

      invalid_attributes = valid_attributes.merge(name: nil)
      item = Item.new(invalid_attributes)
      expect(item).not_to be_valid
      expect(item.errors[:name]).to include("can't be blank")
    end

    it "is invalid without a short description" do
      pending("Score resolution @Jack")

      invalid_attributes = valid_attributes.merge(short_description: nil)
      item = Item.new(invalid_attributes)
      expect(item).not_to be_valid
      expect(item.errors[:short_description]).to include("can't be blank")
    end

    it "is invalid without a score" do
      pending("Score resolution @Jack")

      invalid_attributes = valid_attributes.merge(score: nil)
      item = Item.new(invalid_attributes)
      expect(item).not_to be_valid
      expect(item.errors[:score]).to include("can't be blank")
    end

    it "is invalid with a score outside the range of 0 to 100" do
      pending("Score resolution @Jack")

      invalid_attributes = valid_attributes.merge(score: 150)
       item = Item.new(invalid_attributes)
      expect(item).not_to be_valid
      expect(item.errors[:score]).to include("must be between 0 and 100")
    end
  end
end

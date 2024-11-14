FactoryBot.define do
  factory :item do
    name { "MyString" }
    description { "MyText" }
    price { "9.99" }
    category { "MyString" }
    required_level { 1 }
  end
end

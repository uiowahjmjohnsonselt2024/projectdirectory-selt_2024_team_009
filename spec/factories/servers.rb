FactoryBot.define do
  factory :server do
    name { "MyString" }
    max_players { 1 }
    created_by { 1 }
  end
end

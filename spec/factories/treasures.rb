FactoryBot.define do
  factory :treasure do
    name { "MyString" }
    description { "MyText" }
    points { 1 }
    item { nil }
    unlock_criteria { "MyString" }
  end
end

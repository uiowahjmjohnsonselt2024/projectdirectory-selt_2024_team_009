FactoryBot.define do
  factory :message do
    content { "MyText" }
    user { nil }
    game { nil }
  end
end

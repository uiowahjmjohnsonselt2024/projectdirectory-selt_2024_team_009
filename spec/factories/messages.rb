FactoryBot.define do
  factory :message do
    content { "Test Message" }
    association :user
    association :game
  end
end

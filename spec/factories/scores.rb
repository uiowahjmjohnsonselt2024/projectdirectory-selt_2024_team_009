FactoryBot.define do
  factory :score do
    user { nil }
    server { nil }
    points { 1 }
    level { 1 }
  end
end

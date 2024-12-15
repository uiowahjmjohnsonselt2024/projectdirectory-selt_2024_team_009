FactoryBot.define do
  factory :leaderboard_entry do
    leaderboard { nil }
    user { nil }
    points { 1 }
    rank { 1 }
  end
end

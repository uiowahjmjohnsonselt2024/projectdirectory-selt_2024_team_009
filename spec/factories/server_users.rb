FactoryBot.define do
  factory :server_user do
    user { nil }
    server { nil }
    current_position_x { 1 }
    current_position_y { 1 }
  end
end

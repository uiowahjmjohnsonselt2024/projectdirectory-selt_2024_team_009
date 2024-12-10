FactoryBot.define do
  factory :user do
    username { "TestUser#{rand(1000)}" }
    email { Faker::Internet.email }
    password { "password" }
  end
end


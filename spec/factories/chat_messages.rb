FactoryBot.define do
  factory :chat_message do
    content { "MyText" }
    server { nil }
    user { nil }
  end
end

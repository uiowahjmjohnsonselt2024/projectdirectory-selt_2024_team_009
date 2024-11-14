FactoryBot.define do
  factory :transaction do
    user { nil }
    transaction_type { "MyString" }
    amount { "9.99" }
    currency { "MyString" }
    payment_method { "MyString" }
    item { nil }
    quantity { 1 }
    description { "MyText" }
  end
end

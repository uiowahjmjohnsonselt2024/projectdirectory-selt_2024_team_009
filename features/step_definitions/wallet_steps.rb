Given('a user with a wallet balance of {int} shards') do |balance|
  user = User.create!(
    username: "test_user",
    email: "test_user@example.com",
    password: "password123",
    password_confirmation: "password123"
  )

  user.create_wallet!(balance: balance)
end



Given('an item {string} exists costing {int} shards') do |item_name, price|
  Item.create!(
    name: item_name,
    price: price,
    description: "A powerful item for testing purposes",
    category: "Weapons",
    required_level: 1,
    image_url: "default-item.jpg"
  )
  end

When('the user purchases the item {string}') do |item_name|
  item = Item.find_by(name: item_name)
  expect(item).not_to be_nil, "Item with name '#{item_name}' not found in the database"
  click_button("Buy #{item_name}")
end

Then('their wallet balance should be {int} shards') do |balance|

  expect(current_user.wallet.reload.balance).to eq(balance)
end

Then('the item {string} should be in their inventory') do |name|
  item = Item.find_by(name: name)
  expect(current_user.inventories.exists?(item: item)).to be true
end

Then('they should see {string}') do |message|
  expect(page).to have_content(message)
end

Given('a user without a wallet') do
  @wallet = current_user.wallet
  @wallet.destroy! if @wallet.present?
end

Then('they should be redirected to the wallet creation page') do
  expect(page).to have_current_path(new_wallet_path)
end

When('the user attempts to purchase the item {string}') do |item_name|
  @item = Item.find_by!(name: item_name)
  visit items_path
  within("#item_#{@item.id}") do
    click_button 'Buy Now'
  end
end

Then('their wallet balance should remain {int} shards') do |expected_balance|
  @wallet.reload
  expect(@wallet.balance.to_i).to eq(expected_balance)
end


And('the item {string} should not be in their inventory') do |item_name|
  inventory_item = Inventory.find_by(user: @user, item: Item.find_by(name: item_name))
  expect(inventory_item).to be_nil
end

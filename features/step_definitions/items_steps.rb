Given(/^a user with email "([^"]*)" and password "([^"]*)" and a wallet balance of (\d+) shards$/) do |email, password, balance|
  user = User.create!(
    username: email.split('@').first, # Use the first part of the email as the username
    email: email,
    password: password,
    password_confirmation: password
  )

  user.create_wallet!(balance: balance)
end


Given('the following items exist:') do |table|
  table.hashes.each do |item|
    Item.create!(
      name: item['name'],
      description: item['description'],
      price: item['price'].to_i,
      category: item['category'],
      required_level: item['required_level'].to_i
    )
  end
end

When('I log in as {string} with password {string}') do |email, password|
  visit new_user_session_path
  fill_in 'Email', with: email
  fill_in 'Password', with: password
  click_button 'Log in'
end

When('I visit the shop page') do
  visit items_path
end

Then(/^I should see the following items in the shop:$/) do |table|
  table.hashes.each do |row|
    item_text = [
      row['name'],
      row['description'],
      "Price: #{'%.1f' % row['price'].to_f} Shards",
      "Level: #{row['required_level']}"
    ]
    item_text.each do |text|
      expect(page).to have_content(text)
    end
  end
end


When('I purchase the item {string}') do |item_name|
  item = Item.find_by!(name: item_name)
  click_button("Buy #{item.name}")
end


Then('my wallet balance should be {int} shards') do |balance|
  expect(User.last.wallet.reload.balance).to eq(balance)
end

Then('my wallet balance should remain {int} shards') do |balance|
  expect(User.last.wallet.reload.balance).to eq(balance)
end

Then('the item {string} should be in my inventory') do |item_name|
  item = Item.find_by!(name: item_name)
  expect(User.last.inventories.exists?(item: item)).to be true
end

Then('the item {string} should not be in my inventory') do |item_name|
  item = Item.find_by!(name: item_name)
  expect(User.last.inventories.exists?(item: item)).to be false
end

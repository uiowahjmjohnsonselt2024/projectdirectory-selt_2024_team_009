Given('a server exists with name {string}') do |server_name|
  creator = User.find_or_create_by!(email: 'creator@example.com') do |new_user|
    new_user.username = 'creator'
    new_user.password = 'password123'
    new_user.password_confirmation = 'password123'
  end

  server = Server.create!(
    name: server_name,
    max_players: 10,
    status: "pending",
    creator: creator
  )
  puts "Created server with name: #{server.name}"
  puts(Server.pluck(:name)).inspect
end

Given('I am logged in as a user with email {string} and password {string} and want to visit servers page') do |email, password|
  user = User.find_or_create_by!(email: email) do |new_user|
    new_user.password = password
    new_user.password_confirmation = password
    new_user.username = email.split('@').first # Use the first part of the email as the username
  end

  visit '/users/sign_in'
  fill_in 'user_email', with: email
  fill_in 'user_password', with: password
  click_button 'Log in'
  click_link 'Your Servers'
  expect(page).to have_content("My Created Servers")
end


Given('the server has max players {int}') do |max_players|
  @server.update!(max_players: max_players)
end

Given('a user with email {string} has {int} shards') do |email, shards|
  user = User.find_or_create_by!(email: email) do |new_user|
    new_user.username = email.split('@').first
    new_user.password = 'password123'
    new_user.password_confirmation = 'password123'
  end

  # Ensure the user has a wallet with the specified shards
  wallet = user.wallet || user.create_wallet!(balance: shards)
  wallet.update!(balance: shards)
end

Given('all users have joined the server') do
  User.all.each do |user|
    ServerUser.create!(user: user, server: @server, turn_order: user.id)
  end
end

When('I view the server named {string}') do |server_name|
  page.refresh
  expect(page).to have_content(server_name) # Debugging line to ensure the name is visible on the page
  row = find('tr', text: server_name, match: :first)
  within(row) do
    click_link 'Show'
  end
  expect(page).to have_content('Status: Pending')
end


Then(/^they should see the server's status as "([^"]*)"$/) do |message|
  expect(page).to have_content(message)
end

Then('the {string} button should not be visible') do |button_text|
  expect(page).not_to have_button(button_text)
end

Then('the {string} button should be visible') do |button_text|
  expect(page).to have_button(button_text)
end

When('the server creator clicks {string}') do |button_text|
  click_button button_text
end

Then('the game should be marked as {string}') do |status|
  expect(@server.reload.status).to eq(status)
end

And(/^the wallet balance of "([^"]*)" should be (\d+) shards$/) do |email, expected_balance|
  page.refresh
  user = User.find_by!(email: email)
  expect(user.wallet.reload.balance.to_i).to eq(expected_balance)
end

Given(/^"([^"]*)" adds (\d+) shards to their wallet$/) do |email, amount|
  user = User.find_by!(email: email)
  user.wallet.update!(balance: user.wallet.balance + amount)
end

And(/^"([^"]*)" is the creator of the server$/) do |email|
  creator = User.find_by!(email: email)
  @server = Server.find_by!(name: "Shard Server")
  @server.update!(creator: creator)

end

When(/^"([^"]*)" attempts to join the game$/) do |email|
  user = User.find_by!(email: email)
  login_as(user, scope: :user) # Log in as the specified user
  visit server_path(@server)  # Replace @server with the appropriate server reference
  click_button 'Join Game'   # Simulate clicking the "Join Game" button
end

Then(/^they should be redirected to the transaction page$/) do
  expect(current_path).to eq(new_transaction_path) # Ensure the current path is the transaction page
end

When(/^I fill in "([^"]+)" with "([^"]+)"$/) do |field_label, value|
  fill_in field_label, with: value
end


When(/^I select "([^"]*)" as the payment method$/) do |payment_method|
  select payment_method, from: "Payment Method"
end

When(/^I click the "([^"]*)" button$/) do |button_text|
  click_button button_text
end


Then(/^they should be redirected to the game page$/) do
  expect(current_path).to eq(game_path(@server)) # Replace @server with the correct server variable
end

Given(/^my wallet balance is (\d+) shards$/) do |balance|
  current_user.wallet.update!(balance: balance.to_i)
end


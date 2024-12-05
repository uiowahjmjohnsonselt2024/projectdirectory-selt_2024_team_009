Given('a server exists with name {string}') do |server_name|
  @server = Server.create!(name: server_name, max_players: 3, status: 'pending')
end

Given('the server has max players {int}') do |max_players|
  @server.update!(max_players: max_players)
end

Given('a user with email {string} has {int} shards') do |email, shard_balance|
  user = User.create!(
    username: email.split('@').first,
    email: email,
    password: 'password123',
    password_confirmation: 'password123'
  )
  user.create_wallet!(balance: shard_balance)
end

Given('all users have joined the server') do
  User.all.each do |user|
    ServerUser.create!(user: user, server: @server, turn_order: user.id)
  end
end

When('the server creator views the server page') do
  creator = @server.creator
  login_as(creator, scope: :user) # Assuming Devise for authentication
  visit server_path(@server)
end

Then('they should see {string}') do |message|
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
  user = User.find_by!(email: email)
  expect(user.wallet.reload.balance.to_i).to eq(expected_balance)
end

Given(/^"([^"]*)" adds (\d+) shards to their wallet$/) do |email, amount|
  user = User.find_by!(email: email)
  user.wallet.update!(balance: user.wallet.balance + amount)
end

And(/^"([^"]*)" is the creator of the server$/) do |email|
  creator = User.find_by!(email: email)
  @server.update!(creator: creator)
end

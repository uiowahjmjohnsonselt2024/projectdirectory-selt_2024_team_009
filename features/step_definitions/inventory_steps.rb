
Given('I am logged in as a user with email {string} and password {string}') do |email, password|
  fill_in 'user_email', with: email
  fill_in 'user_password', with: password
  click_button 'Log in'
end

Given('I navigate to the inventory page') do
  click_link 'Inventory'

end

Given('the database is seeded with default items') do
  Rails.application.load_seed
end

When('I visit the items index page') do
  visit items_path
end

Then('I should see a list of all items') do
  Item.all.each do |item|
    expect(page).to have_content(item.name)
    expect(page).to have_content(item.description)
    expect(page).to have_content(item.price)
    expect(page).to have_content(item.category)
  end
end

And('each item should display its name, description, price, and category') do
  Item.all.each do |item|
    within("#item_#{item.id}") do
      expect(page).to have_content(item.name)
      expect(page).to have_content(item.description)
      expect(page).to have_content(item.price)
      expect(page).to have_content(item.category)
    end
  end
end

Given('an item {string} exists') do |item_name|
  @item = Item.find_by(name: item_name)
  raise "Item #{item_name} does not exist" unless @item
end

When('I visit the item details page for {string}') do |item_name|
  item = Item.find_by(name: item_name)
  visit item_path(item)
end

Then('I should see the item\'s name, description, price, category, required level, and image') do
  expect(page).to have_content(@item.name)
  expect(page).to have_content(@item.description)
  expect(page).to have_content(@item.price)
  expect(page).to have_content(@item.category)
  expect(page).to have_content(@item.required_level)
  expect(page).to have_css("img[src*='#{@item.image_url}']")
end


When('I select {string} from {string}') do |option, field|
  select option, from: field
end


When('I click {string}') do |button|
  click_button button
end

Then('I should see {string}') do |message|
  expect(page).to have_content(message)
end

Then('I should see {string} in the list of items') do |item_name|
  expect(page).to have_content(item_name)
end

When('I visit the edit page for {string}') do |item_name|
  item = Item.find_by(name: item_name)
  visit edit_item_path(item)
end

When('I change {string} to {string}') do |field, value|
  fill_in field, with: value
end

Then('the item {string} should have a price of {string}') do |item_name, price|
  item = Item.find_by(name: item_name)
  expect(item.price).to eq(price.to_f)
end

When('I delete the item {string}') do |item_name|
  item = Item.find_by(name: item_name)
  within("#item_#{item.id}") do
    click_link 'Delete'
  end
end

Then('I should not see {string} in the list of items') do |item_name|
  expect(page).not_to have_content(item_name)
end

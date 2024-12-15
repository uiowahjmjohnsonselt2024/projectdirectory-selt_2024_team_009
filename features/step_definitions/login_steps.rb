Given('a user with email {string} and password {string}') do |email, password|
    # Here, you would create a user in your test database or mock setup
    @user = User.create!(email: email, password: password, username: "email")
  end
  
  When('I go {string}') do |path|
    visit path
  end
  
  When('I fill {string} with {string}') do |field, value|
    fill_in field, with: value
  end
  
  When('I press {string}') do |button|
    click_button button
  end
  

  
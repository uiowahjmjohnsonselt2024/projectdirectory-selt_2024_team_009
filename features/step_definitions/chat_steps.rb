

Then("I should see the chatbox in the lower-left corner") do
  expect(page).to have_content("Type a message...")
  #expect(page).to have_css("#chatbox", visible: true, wait: 5)
end

Then("I should see a message input field and a send button") do
  expect(page).to have_css("input#chat-input")
  expect(page).to have_button("Send")
end

When("I type {string} in the chatbox") do |message|
  fill_in "chat-input", with: message
end

When("I click the send button") do
  click_button "Send"
end

Then("I should see {string} appear in the chatbox") do |message|
  within("#messages") do
    expect(page).to have_content(message)
  end
end

When("{string} sends {string}") do |email, message|
  user = User.find_by!(email: email)
  Message.create!(content: message, user: user, game: @server)
  ActionCable.server.broadcast(
    "chat_#{@server.id}",
    message: ApplicationController.renderer.render(partial: "messages/message", locals: { message: Message.last })
  )
end

Feature: In-game Chatbox
  As a user
  I want to use the chatbox during a game
  So that I can communicate with other players

  Background:
    Given I am logged in as a user with email "player1@example.com" and password "password123" and want to visit servers page
    And a server exists with name "Shard Server"
    And a user with email "creator@example.com" has 300 shards
    And a user with email "player2@example.com" has 300 shards
    And "creator@example.com" is the creator of the server
    And all users have joined the server
    And I view the server named "Shard Server"

  Scenario: Chatbox is visible on the game screen
    Then I should see the chatbox in the lower-left corner
    And I should see a message input field and a send button

  Scenario: Sending a message in the chatbox
    When I type "Hello, team!" in the chatbox
    And I click the send button
    Then I should see "Hello, team!" appear in the chatbox

  Scenario: Receiving a message from another player
    When "player2@example.com" sends "Good luck!"
    Then I should see "Good luck!" appear in the chatbox

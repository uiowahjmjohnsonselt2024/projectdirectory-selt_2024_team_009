Feature: Start Game with Shards Deduction

  Background:
    Given I am logged in as a user with email "creator@example.com" and password "password123" and want to visit servers page
    And a server exists with name "Shard Server"
    And a user with email "creator@example.com" has 300 shards
    And a user with email "player1@example.com" has 200 shards
    And a user with email "player2@example.com" has 200 shards
    And "creator@example.com" is the creator of the server
    And all users have joined the server

  Scenario: Starting the game with sufficient shards
    When I view the server named "Shard Server"
    Then they should see the server's status as "Start Game"
    And the "Start Game" button should be visible
    When the server creator clicks "Start Game"
    And the wallet balance of "creator@example.com" should be 100 shards
    And the wallet balance of "player1@example.com" should be 0 shards
    And the wallet balance of "player2@example.com" should be 0 shards

  Scenario: Insufficient shards for some players
    Given a user with email "player2@example.com" has 50 shards
    And I view the server named "Shard Server"
    Then they should see "Not all players have 200 shards"
    And the "Start Game" button should not be visible

  Scenario: Redirect to transaction page due to insufficient shards
    Given a user with email "creator@example.com" has 50 shards
    And I view the server named "Shard Server"
    And they should see "Not all players have 200 shards. Ensure every player has sufficient balance to start the game"
    And I fill in "Number of Shards" with "200"
    And I fill in "Credit Card Number" with "1234 5678 9012 3456"
    And I fill in "Expiry Date (MM/YY)" with "12/25"
    And I fill in "CVV" with "123"
    And I click the "Purchase Shards" button
    Then I should see "200 Shards successfully purchased!"
    Then I should see "Shards successfully purchased"
    And the wallet balance of "creator@example.com" should be 250 shards

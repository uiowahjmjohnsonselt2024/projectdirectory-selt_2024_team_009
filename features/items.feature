Feature: Item Purchase
  As a player
  I want to view items in the shop
  And purchase items if I have sufficient shards

  Background:
    Given a user with email "player@example.com" and password "password123" and a wallet balance of 100 shards
    And the following items exist:
      | name          | description                     | price | category     | required_level |
      | AP Booster    | Increases action points         | 30    | Consumable   | 1              |
      | Mirror Shield | Reflects an opponent's attack   | 170   | Equipment    | 3              |
      | Time Scroll   | Grants an extra turn            | 50    | Magical Item | 5              |

  Scenario: Viewing items in the shop
    When I log in as "player@example.com" with password "password123"
    And I visit the shop page
    Then I should see the following items in the shop:
      | name          | description                     | price | required_level |
      | AP Booster    | Increases action points         | 30    | 1              |
      | Mirror Shield | Reflects an opponent's attack   | 170   | 3              |
      | Time Scroll   | Grants an extra turn            | 50    | 5              |

  Scenario: Purchasing an item with sufficient shards
    When I log in as "player@example.com" with password "password123"
    And I visit the shop page
    And I purchase the item "AP Booster"
    Then I should see "Item purchased successfully!"
    And my wallet balance should be 70 shards
    And the item "AP Booster" should be in my inventory

  Scenario: Attempting to purchase an item with insufficient shards
    When I log in as "player@example.com" with password "password123"
    And I visit the shop page
    And I purchase the item "Mirror Shield"
    Then I should see "Insufficient Shards to buy this item."
    And my wallet balance should remain 100 shards
    And the item "Mirror Shield" should not be in my inventory

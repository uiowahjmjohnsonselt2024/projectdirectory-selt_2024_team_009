Feature: Wallet integration with Items

  Scenario: Purchasing an item with sufficient shards
    Given a user with a wallet balance of 100 shards
    And an item "Assault Rifle (M416)" exists costing 50 shards
    When the user purchases the item "Assault Rifle (M416)"
    Then their wallet balance should be 50 shards
    And the item "Assault Rifle (M416)" should be in their inventory



  Scenario: Attempting to purchase an item with insufficient shards
    Given a user with a wallet balance of 30 shards
    When the user attempts to purchase the item "Shotgun (S12K)"
    Then their wallet balance should remain 30 shards
    And the item "Shotgun (S12K)" should not be in their inventory


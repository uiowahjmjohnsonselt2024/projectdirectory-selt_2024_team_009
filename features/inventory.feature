Feature: Item management
  As a user
  I want to manage items
  So that I can view, create, edit, and delete items effectively

  Background:
    Given the database is seeded with default items

  Scenario: Viewing all items
    When I visit the items index page
    Then I should see a list of all items
    And each item should display its name, description, price, and category

  Scenario: Viewing a single item
    Given an item "Assault Rifle (M416)" exists
    When I visit the item details page for "Assault Rifle (M416)"
    Then I should see the item's name, description, price, category, required level, and image


  Scenario: Deleting an item
    Given an item "Smoke Grenade" exists
    When I delete the item "Smoke Grenade"
    Then I should not see "Smoke Grenade" in the list of items
    And I should see "Item successfully deleted"

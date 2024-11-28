Feature: Iventory management
  As a user
  I want to manage my inventory
  So that I can view, create, edit, and delete items effectively

  Background:
    Given a user with email "test@example.com" and password "asdf1234"
    When I go "/users/sign_in"
    And I fill "user_email" with "test@example.com"
    And I fill "user_password" with "asdf1234"
    And I press "Log in"
    When I go "/inventories"
    And the database is seeded with default items

  Scenario: Viewing all items
    Given the user with email "test@example.com" has items with names "Assault Rifle (M416), Shotgun (S12K)" in their inventory
    When I visit the inventory index page
    Then I should see a list of these items "Assault Rifle (M416), Shotgun (S12K)"


  Scenario: Viewing a single item
    Given an item "Assault Rifle (M416)" exists
    When I visit the item details page for "Assault Rifle (M416)"
    Then I should see the item's name, description, price, category, required level, and image


  Scenario: Deleting an item
    Given an item "Assault Rifle (M416)" exists
    When I delete the item "Assault Rifle (M416)"
    Then I should not see "Assault Rifle (M416)" in the list of items
    And I should see "Item successfully deleted"

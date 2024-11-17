Feature: User Creation
    Scenario: Valid input creates user
        When I go "/users/sign_up"
        And I fill "user_email" with "test@example.com"
        And I fill "user_username" with "test"
        And I fill "user_password" with "asdf1234"
        And I fill "user_password_confirmation" with "asdf1234"
        And I press "Sign up"
        Then I should see "test@example.com"

    Scenario: Invalid input rejects creation
        Given a user with email "test@example.com" and password "asdf12345"
        When I go "/users/sign_up"
        And I fill "user_username" with "test"
        And I fill "user_email" with "test@example.com"
        And I press "Sign up"
        Then I should see "Sign up"
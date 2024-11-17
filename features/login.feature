Feature: User Authentication
    Scenario: Valid Credentials logs in
        Given a user with email "test@example.com" and password "asdf1234"
        When I go "/users/sign_in"
        And I fill "user_email" with "test@example.com"
        And I fill "user_password" with "asdf1234"
        And I press "Log in"
        Then I should see "Profile"

    Scenario: Invalid credentials fails silently
        Given a user with email "test@example.com" and password "asdf12345"
        When I go "/users/sign_in"
        And I fill "user_email" with "test@example.com"
        And I fill "user_password" with "asdf1234"
        And I press "Log in"
        Then I should see "Email"
Feature: Login
  In order to login
  As a tutor
  I want to get access

  Scenario: Basic Access Protection
    Given I am on the home page
      And I am not logged in
     Then I should see "Login"

  Scenario: Basic Login
    Given I am on the account sign in page
      And a tutor with "tutor@student.tugraz.at/secret"
     When I fill in "Email" with "tutor@student.tugraz.at"
      And I fill in "Password" with "secret"
      And I click on button "Sign in"
     Then I should see "tutor@student.tugraz.at"

  Scenario: Wrong Username/Password combination
    Given I am on the account sign in page
      And no account with email "wrong.email@student.tugraz.at" exists
     When I fill in "Email" with "wrong.email@student.tugraz.at"
      And I click on button "Sign in"
     Then I should see "Invalid email or password."



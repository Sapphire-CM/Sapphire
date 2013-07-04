Feature: Password reset 
  In order to reset password
  As a user
  I want to regain access to my account
  
  Scenario: User with correct email
    Given an account with email "john.doe@student.tugraz.at"
    And I am on the password reset page
    When I fill in "Email" with "john.doe@student.tugraz.at"
    And I click on button "Send me reset password instructions"
    Then I should see "You will receive an email with instructions about how to reset your password in a few minutes."

  Scenario: User with incorrect email
    Given no account with email "john.doe@student.tugraz.at" exists    
    And I am on the password reset page
    When I fill in "Email" with "john.doe@student.tugraz.at"
    And I click on button "Send me reset password instructions"
    Then I should see "not found"
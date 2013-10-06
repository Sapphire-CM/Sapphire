Feature: Term
  In order to work with terms
  As a tutor
  I want to create, update and delete terms

  @javascript
  Scenario: Create a term
    Given there is a course "My Course"
      And I am logged in
      And I am on the home page
     When I create a new term "My New Term" on course "My Course"
     Then I should see term entry "My New Term" on course "My Course"

  @javascript
  Scenario: Update a term
    Given there is a term "Strange Term" in a course "My Course"
      And I am logged in
      And I am on the home page
     When I update the term "Strange Term" on course "My Course" to "Pretty Term"
     Then I should see term entry "Pretty Term" on course "My Course"
      And I should find the term "Pretty Term" on course "My Course"

  @javascript
  Scenario: Delete a term
    Given there is a term "Strange Term" in a course "My Course"
      And I am logged in
      And I am on the home page
     When I delete the term "Strange Term" on course "My Course"
     Then I should not see term entry "Strange Term" on course "My Course"
      And I should not find the term "Strange Term" on course "My Course"

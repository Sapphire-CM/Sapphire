Feature: Managing terms
  In order to work with terms
  As a tutor
  I want to create, update and delete terms

  @javascript
  Scenario: Create a term
    Given there is a course "My Course"
      And I am logged in as an admin
      And I am on the home page
     When I click on link "Add Term"
      And I fill in "Title" with "My New Term"
      And I click on button "Save"
     Then I should find the term "My New Term" on course "My Course"
      And I should see "My New Term"

  # @javascript
  # Scenario: Update a term
  #   Given there is a term "Strange Term" in a course "My Course"
  #     And I am logged in as an admin
  #     And I am on the home page
  #    When I update the term "Strange Term" on course "My Course" to "Pretty Term"
  #    Then I should find the term "Pretty Term" on course "My Course"
  #     And I should see "Pretty Term"

  # @javascript
  # Scenario: Delete a term
  #   Given there is a term "Strange Term" in a course "My Course"
  #     And I am logged in as an admin
  #     And I am on the home page
  #    When I delete the term "Strange Term" on course "My Course"
  #    Then I should not find the term "Strange New Term" on course "My Course"
  #     And I should not see "Strange New Term"

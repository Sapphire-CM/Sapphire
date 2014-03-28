Feature: Managing exercises
  In order to manage exercises
  As an lecturer or admin
  I want to create, update and delete exercises

  Background:
    Given I am logged in as an admin
      And there are these terms for "HCI"
        | title   |
        | SS 2014 |

  Scenario: Adding Exercises
    When I navigate to the term "SS 2014" of course "HCI"
     And I click on link "Exercises"
     And I click on link "Add Exercise"
     And I fill in "Title" with "HE-Plan"
     And I click on button "Save"
    Then I should see "Exercise was successfully created."
     And I should see "HE-Plan"

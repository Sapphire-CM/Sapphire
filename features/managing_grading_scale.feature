Feature: Managing grading scale
  In order to manage the grading scale of a term
  As an admin
  I want to be able to update the grading scale

  Scenario: Viewing grading scale
    Given I am logged in as an admin
      And there is a term "SS 2014" in a course "HCI"
    When I navigate to the term "SS 2014" of course "HCI"
     And I click on link "Administrate"
     And I click on link "Grading Scale"
    Then I should see a table "grading_scale_table" with these elements
      | text |
      | 1    |
      | 2    |
      | 3    |
      | 4    |
      | 5    |

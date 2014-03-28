Feature: Importing students
  In order to import students
  As a lecturer or admin
  I want upload a csv-export from tug online and see live feedback of the progress


  Scenario: Navigating to the imports page
    Given I am logged in as an admin
      And there is a term "SS 2014" in a course "HCI"
    When I navigate to the term "SS 2014" of course "HCI"
     And I click on link "Administrate"
     And I click on link "Imports"
    Then I should see "HCI: SS 2014"
     And I should see "Upload CSV"

  Scenario: Importing correct CSV
    Pending

  Scenario: Importing malformed CSV
    Pending

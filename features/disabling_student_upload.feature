Feature: Disabling student upload
  In order to disable upload of submissions for students
  As an admin
  I want to enable and disable the upload feature

  Background:
  Given I am logged in as an admin
    And there is a solitary exercise "MC Test" for term "SS 2014" of course "HCI"
    And there is a group exercise "Ex 1: HE Plan" for term "SS 2014" of course "HCI"
    And there are no uploads allowed for "Ex 1: HE Plan" for term "SS 2014" of course "HCI"

  Scenario: Disabling student upload
    Given I am on the home page
    When I click on link "SS 2014"
     And I click on link "MC Test"
     And I click on link "Administrate"
     And I untick the check box "Enable student uploads"
     And I click on button "Save"
    Then no student upload should be allowed for "MC Test"

  Scenario: Enabling student upload
    Given I am on the home page
    When I click on link "SS 2014"
     And I click on link "Ex 1: HE Plan"
     And I click on link "Administrate"
     And I tick the check box "Enable student uploads"
     And I click on button "Save"
    Then student uploads should be allowed for "MC Test"

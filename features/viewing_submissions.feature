Feature: Viewing submissions
  In order to view submissions
  As a tutor
  I want to be able to view all submissions of my tutorial group

  Background:
    Given there are these terms for "HCI"
        | title   |
        | SS2014 |
      And I am logged in as a tutor of "T1" of term "SS2014" of course "HCI"
      And there is a group exercise "HE Report" for term "SS2014" of course "HCI"
      And there is a solitary exercise "HE Log Files" for term "SS2014" of course "HCI"
      And there are 5 submissions for "HE Report" of term "SS2014" of course "HCI" for tutorial group "T1"
      And there are 5 submissions for "HE Report" of term "SS2014" of course "HCI" for tutorial group "T2"
      And there are 10 submissions for "HE Log Files" of term "SS2014" of course "HCI" for tutorial group "T1"

  Scenario: Navigating to the submissions
    Given I am on the home page
    When I click on link "SS2014"
     And I click on link "Exercises"
     And I click on link "HE Report"
    Then I should see "5 Submissions"

  Scenario: Viewing submissions of group exercises
    Given I am on the submissions page of exercise "HE Report"
    Then I should see "5 Submissions"

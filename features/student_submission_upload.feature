@focus
Feature: Student submission upload
  In order to upload submissions
  As a student
  I want be able to upload new submissions and update already submitted submissions


  Background:
    Given I am logged in as a student of term "SS 2014" of course "HCI"
      And there is a group exercise "Ex 1: HE-Plan" for term "SS 2014" of course "HCI"
      And there is a solitary exercise "Ex 2.1: Log Files" for term "SS 2014" of course "HCI"
      And I am in a group for term "SS 2014" of course "HCI" with following users
        | email                        |
        | another_student@sapphire.com |

  Scenario: Navigating to the uploads page
    When I navigate to the term "SS 2014" of course "HCI"
     And I click on link "Exercises"
     And I click on link "Ex 1: HE-Plan"
    Then I should see a button with "Upload Submission"


  Scenario: Uploading solitary submissions
    When I navigate to the submission form of exercise "Ex 1: HE-Plan"
     And I attach "submission.zip" to "File"
     And I click on button "Upload Submission"
    Then I should see "Successfully uploaded submission"
     And I should see "submission.zip"
    When I sign in as "another_student@sapphire.com"
     And I navigate to the submission form of exercise "Ex 1: HE-Plan"
    Then I should see "submission.zip"
    When I attach "submission_2.zip" to "File"
     And I click on button "Update Submission"
    Then I should see "Successfully updated submission"
     And I should see "submission_2.zip"
     And there should be 1 submission

   Scenario: Uploading group submissions
     When I navigate to the submission form of exercise "Ex 2.1: Log Files"
      And I attach "submission.zip" to "File"
      And I click on button "Upload Submission"
     Then I should see "Successfully uploaded submission"
      And I should see "submission.zip"
     When I sign in as "another_student@sapphire.com"
      And I navigate to the submission form of exercise "Ex 2.1: Log Files"
     Then I should not see "submission.zip"
     When I attach "submission_2.zip" to "File"
      And I click on button "Upload Submission"
     Then I should see "Successfully uploaded submission"
      And I should see "submission_2.zip"
      And there should be 2 submissions

  Scenario: Updating group submissions
    When I navigate to the submission form of exercise "Ex 2.1: Log Files"
     And I attach "submission.zip" to "File"
     And I click on button "Upload Submission"
    Then I should see "Successfully uploaded submission"
     And I should see "submission.zip"
    When I attach "submission_2.zip" to "File"
     And I click on button "Update Submission"
    Then I should see "Successfully updated submission"
     And I should see "submission_2.zip"
     And I should not see "submission.zip"
     And there should be 1 submission

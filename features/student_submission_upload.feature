Feature: Student submission upload
  In order to upload submissions
  As a student
  I want be able to upload new submissions and update already submitted submissions


  Background:
    Given I am logged in as a student of term "SS 2014" of course "HCI"
      And there is an exercise "Ex 1: HE-Plan" for term "SS 2014" of course "HCI"

  Scenario: Navigating to the uploads page
    When I navigate to the term "SS 2014" of course "HCI"
     And I click on link "Exercises"
     And I click on link "Ex 1: HE-Plan"
    Then I should see "Upload Submission"

  Scenario: Uploading submissions
    When I navigate to the exercise "Ex 1: HE-Plan"
     And I attach "submission.zip" to "ZIP-File"
     And I click on button "Upload Submission"
    Then I should see "Submission successfully uploaded"

  Scenario: Updating submissions
    Given I have submitted a submission "submission.zip" for "Ex 1: HE-Plan"
    When I navigate to the exercise "Ex 1: HE-Plan"
     And I attach "submission_2.zip" to "something"
     And I click on button "Update Submission"
    Then I should see "Submission successfully updated"
     And I should see "submission_2.zip"

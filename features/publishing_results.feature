Feature: Publishing results
  In order to publish results
  As a lecturer or an admin
  I want to publish results and revoke publications

  Background:
    Given there is a term "SS 2014" in a course "HCI"
      And there is an exercise "Ex 1: HE-Plan" in term "SS 2014"
      And there is a tutorial group "T1" in term "SS 2014"

  # Scenario: Navigating to the result publications
  #   Given I am logged in as an admin
  #     And I am on the home page
  #   When I click on link "SS 2014"
  #    And I click on link "Exercises"
  #    And I click on link "Ex 1: HE-Plan"
  #    And I click on link "Administrate"
  #    And I click on link "Publish Results"
  #   Then I should see "T1"
  #    And I should see a button with "Publish T1"

  Scenario: Publishing and concealing results
    Given I am logged in as an admin
    When I navigate to the results publication page of exercise "Ex 1: HE-Plan"
     And I click on button "Publish T1"
    Then I should see "Successfully published results for Ex 1: HE-Plan for T1"
    When I click on button "Conceal T1"
    Then I should see "Successfully concealed results for Ex 1: HE-Plan for T1"

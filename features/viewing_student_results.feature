Feature: Viewing student results
  In order to view results of an exercise
  As a student
  I want to see my point reductions

  # Background:
  #   Given I am logged in as a student of term "SS 2014" of course "HCI"
  #     And there are these exercises for term "SS 2014" for course "HCI"
  #       | title           |
  #       | Ex 1: HE-Plan   |
  #       | Ex 2: HE-Report |

  #     And all results of exercise "Ex 1: HE-Plan" are published

  # Scenario: Navigating to the results
  #   Given I am on the home page
  #    And I have submitted a submission "simple_submission.txt" for "Ex 1: HE-Plan"
  #   When I click on link "SS 2014"
  #    And I click on link "Exercises"
  #    And I click on link "Ex 1: HE-Plan"
  #    And I click on link "Results"
  #   Then I should see the subtitle "Results"

  # Scenario: Viewing unpublished results
  #   Given I am on the home page
  #   When I click on link "SS 2014"
  #    And I click on link "Exercises"
  #    And I click on link "Ex 2: HE-Report"
  #   Then I should not see a link with "Results"

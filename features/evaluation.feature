Feature: Evaluation of Students
  In order to evaluate students
  As a tutor
  I want to see all student groups at once

@javascript
  Scenario: Evaluation Table for solitary student groups
    Given there is a term called "Term 2013"
    Given there is a tutorial group called "T1" in term "Term 2013"
    Given there is an exercise called "Exercise 1" in term "Term 2013"
    Given there are 5 submissions for "Exercise 1"
    Given there are 10 students in "T1" registered for "Exercise 1"
    Given there are these rating groups for "Exercise 1"
      | title    |
      | Identity |
      | Format   |
      | Content  |
     And I am logged in
    When I visit the evaluations page of "Exercise 1"
    Then I should see "Evaluations of Exercise 1"
     And I should see "Identity"
     And I should see "Format"
     And I should see "Content"
     And I should see "John 7 Doe"




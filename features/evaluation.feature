Feature: Evaluation of Students
  In order to evaluate students
  As a tutor
  I want to see all student groups at once

@javascript
  Scenario: Evaluation Table for solitary student groups
    Given there is a term "Term 2013" in a course "My Course"
      And there is a tutorial group "T1" in term "Term 2013"
      And there is an exercise "Exercise 1" in term "Term 2013"
      And there are 5 submissions for "Exercise 1"
      And there are 10 students in "T1" registered for "Exercise 1"
      And there are these rating groups for "Exercise 1"
      | title    |
      | Identity |
      | Format   |
      | Content  |
     And I am logged in as an admin
    When I visit the evaluations page of "Exercise 1"
    Then I should see "Evaluations of Exercise 1"
     And I should see "Identity"
     And I should see "Format"
     And I should see "Content"
     And I should see "John 7 Doe"




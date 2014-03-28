Feature: Admin home page
  In order to administrate sapphire
  As an admin
  I want to view all courses

  Scenario: Viewing the home page
    Given I am logged in as an admin
      And there are these courses
        |title|
        |HCI|
        |INM|
      And there are these terms for "HCI"
        |title|
        |SS 2012/13|
        |SS 2013/14|
      And there are these terms for "INM"
        |title|
        |WS 2012|
        |WS 2013|
    When I navigate to the home page
    Then I should see "HCI"
      And I should see "SS 2012/13"
      And I should see "SS 2013/14"
      And I should see "INM"
      And I should see "WS 2012"
      And I should see "WS 2013"

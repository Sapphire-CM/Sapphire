Feature: Download submissions zip
  In order to download the submissions zip
  As a tutor
  I want to download all the submissions of an exercise

  # Background:
  #   Given there are these terms for "HCI"
  #     | title   |
  #     | SS2014 |
  #   And there are these tutorial groups for term "SS2014" of course "HCI"
  #     | title |
  #     | T1    |
  #     | T2    |
  #   And I am logged in as a tutor of "T1" of term "SS2014" of course "HCI"
  #   And there is a solitary exercise "HE Log Files" for term "SS2014" of course "HCI"
  #   And there are 10 submissions for "HE Log Files" of term "SS2014" of course "HCI" for tutorial group "T1"
  #   And there are 7 submissions for "HE Log Files" of term "SS2014" of course "HCI" for tutorial group "T2"

    # Scenario: Downloading submissions of a solitary exercise
    #   Given I am on the submissions page of exercise "HE Log Files"
    #   When I click on link "Download"
    #   Then I should get a download with the filename "he-log-files.zip"

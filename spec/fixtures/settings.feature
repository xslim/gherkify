Feature: Settings screen
  In order to change app settings,
  As a User,
  I want to have settings screen.

  Scenario: Accessing Settings from app
    Given I am on any city screen
     Then I should see settings button
     When I touch settings button
     Then I should see settings screen

  Scenario: Changing Temperature units
    Given App 'Temperature scale' defaults is 'C'
      And selected city current temperature is 10
      And I am on Settings screen
     Then I should see 'Temperature scale' label
      And I should see 'C' is selected in 'Temperature scale' segmented control
     When I touch 'F' on "Temperature scale" segmented control
      And I touch 'Done' button
     Then I should see selected city current temperature is 50

  Scenario: Entering cities setting screen
    Given I am on Settings screen
     Then I should see 'Cities' label
     When I touch 'Cities'
     Then I should see 'Cities' screen

Feature: Cities
  In order view weather for different cities,
  As a User,
  I want to have ability to manage cities.

  Scenario: Searching
    Given I am on 'Kiev' city screen
     When I enter cities setting screen
      And I touch add button
      And I enter 'Amsterdam' in search field
     Then I should see 'Amsterdam' table row

  Scenario: Adding
    Given I am on 'Kiev' city screen
     When I enter cities setting screen
      And I add 'Amsterdam' city
      And I save settings
     Then I should see 'Amsterdam' city screen

  Scenario: Removing
    Given I am on 'Kiev' city screen
     When I enter cities setting screen
     Then I should see 'Kiev' table row
     When I touch Delete on 'Kiev' table row
     Then I should not see 'Kiev' table row
     When I save settings
     Then I should not see 'Kiev' city screen
      And there should not be 'Kiev' city screen

  Scenario: Ordering
    Given there are the existing cities 'Kiev', 'London' and 'Amsterdam' 
      And I am on first city screen
     Then I should see 'Kiev' city screen
     When I enter cities setting screen
      And I order cities to 'London', 'Kiev' and 'Amsterdam'
      And I save settings
     Then I should see 'London' city screen
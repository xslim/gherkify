Feature: Rating a stand
  Scenario: Find and rate a stand from the list
    Given I am on the foodstand list
    Then I should see a "rating" button
    And I should not see "Dixie Burger & Gumbo Soup"

    When I touch the "rating" button
    Then I should see "Dixie Burger & Gumbo Soup"

    When I touch "Dixie Burger & Gumbo Soup"
    Then I should see details for "Dixie Burger & Gumbo Soup"

    When I touch the "rate_it" button
    Then I should see the rating panel

    When I touch "star5"
    And I touch "rate"
    Then "Dixie Burger & Gumbo Soup" should be rated 5 stars
Feature: Download sales PDF files
  In order to get information to my sales prospects,
  As a Website user,
  I want to download sales PDF files of completed batches from the system.
  
  Background:
    Given the standard QA profiles exist
    And I am logged in as a sales PDFs user
  
  @javascript
  Scenario: Access ZIP file download from multi-entry batch
    Given there exists a completed document batch for multiple websites
    When I view the Sales PDF batches list
    And I double-click on the Sales PDF batch
    Then I should see the batch status within the document batch results
    And I should see the link to download the ZIP file within the document batch results

  Scenario: Download ZIP file
    Given there exists a completed document batch for multiple websites
    When I click on the link to download the ZIP file
    Then my browser should download a file in ZIP format

  @javascript
  Scenario: Access single PDF file download from single-entry batch
    Given there exists a completed document batch for a single website
    When I view the Sales PDF batches list
    And I double-click on the Sales PDF batch
    Then I should see the batch status within the document batch results
    And I should see the link to download the PDF file within the document batch results

  Scenario: Download single PDF file
    Given there exists a completed document batch for a single website
    When I click on the link to download the PDF file
    Then my browser should download a file in PDF format

  @javascript
  Scenario: Can't download if check not completed
    Given I have a document batch in progress
    When I view the Sales PDF batches list
    And I double-click on the Sales PDF batch
    Then I should see the batch status within the document batch results
    And I should not see a link to download a file within the document batch results

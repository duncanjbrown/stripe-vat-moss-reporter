Feature: Generating CSV reports

  Scenario: One charge from one country
    Given there are the following charges in Stripe
      | amount | fee | currency | country |
      | 4900   | 638 | usd      | FR      |
    When I run the CSV export for the period
    Then a CSV file should be created with the contents
      | Invoice Number | Invoice Date | Customer Name | Line Description       | Line Unit Price | Line VAT Amount | Line VAT Rate | Line Gross |
      | FR31012019     | 31-01-2019   | Mr FR         | Sales for January 2019 | 40.83           | 8.17            | 0.2           | 49.0       |

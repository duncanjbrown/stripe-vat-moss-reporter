Feature: Generating CSV reports

  Scenario: One charge from one country
    Given there are the following charges in Stripe
      | amount | fee | currency | country |
      | 4900   | 638 | usd      | FR      |
    When I run the CSV export for the period
    Then a CSV file should be created with the contents
      | Invoice Number | Invoice Date | Customer Name | Line Description       | Line Unit Price | Line VAT Amount | Line VAT Rate | Line Gross |
      | FR31012019     | 31-01-2019   | Mr FR         | Sales for January 2019 | 40.83           | 8.17            | 0.2           | 49.0       |

  Scenario: Two charges from one country
    Given there are the following charges in Stripe
      | amount | fee | currency | country |
      | 4900   | 638 | usd      | FR      |
      | 4900   | 638 | usd      | FR      |
    When I run the CSV export for the period
    Then a CSV file should be created with the contents
      | Invoice Number | Invoice Date | Customer Name | Line Description       | Line Unit Price | Line VAT Amount | Line VAT Rate | Line Gross |
      | FR31012019     | 31-01-2019   | Mr FR         | Sales for January 2019 | 81.67           | 16.33            | 0.2           | 98.0      |

  Scenario: Charges from separate countries
    Given there are the following charges in Stripe
      | amount | fee | currency | country |
      | 4900   | 638 | usd      | DE      |
      | 4900   | 638 | usd      | ES      |
    When I run the CSV export for the period
    Then a CSV file should be created with the contents
      | Invoice Number | Invoice Date | Customer Name | Line Description       | Line Unit Price | Line VAT Amount | Line VAT Rate | Line Gross |
      | DE31012019     | 31-01-2019   | Mr DE         | Sales for January 2019 | 41.18           | 7.82            | 0.19          | 49.0       |
      | ES31012019     | 31-01-2019   | Mr ES         | Sales for January 2019 | 40.5            | 8.5             | 0.21          | 49.0       |


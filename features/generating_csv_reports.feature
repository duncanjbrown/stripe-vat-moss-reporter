Feature: Generating CSV reports

  Scenario: One charge from one country
    Given there are the following charges in Stripe
      | amount | fee | currency | country |
      | 4900   | 638 | usd      | FR      |
    When I run the CSV export for the period
    Then a CSV file should be created with the contents
      | Invoice Number  | Invoice Date | Customer Name | Line Description       | Line Unit Price | Line VAT Amount | Line VAT Rate | Line Gross | Currency |
      | FR-USD-31012019 | 31-01-2019   | Mr FR         | Sales for January 2019 | 40.83           | 8.17            | 0.2           | 49.0       | USD      |
    And the summary report should read
      """
      Gross amount processed: 49.00 USD
      Total fees paid: 6.38 USD
      """

  Scenario: Two charges from one country
    Given there are the following charges in Stripe
      | amount | fee | currency | country |
      | 4900   | 638 | usd      | FR      |
      | 4900   | 638 | usd      | FR      |
    When I run the CSV export for the period
    Then a CSV file should be created with the contents
      | Invoice Number  | Invoice Date | Customer Name | Line Description       | Line Unit Price | Line VAT Amount | Line VAT Rate | Line Gross | Currency |
      | FR-USD-31012019 | 31-01-2019   | Mr FR         | Sales for January 2019 | 81.67           | 16.33            | 0.2           | 98.0      | USD      |

  Scenario: Charges from separate countries
    Given there are the following charges in Stripe
      | amount | fee | currency | country |
      | 4900   | 638 | usd      | DE      |
      | 4900   | 638 | usd      | ES      |
    When I run the CSV export for the period
    Then a CSV file should be created with the contents
      | Invoice Number  | Invoice Date | Customer Name | Line Description       | Line Unit Price | Line VAT Amount | Line VAT Rate | Line Gross | Currency |
      | DE-USD-31012019 | 31-01-2019   | Mr DE         | Sales for January 2019 | 41.18           | 7.82            | 0.19          | 49.0       | USD      |
      | ES-USD-31012019 | 31-01-2019   | Mr ES         | Sales for January 2019 | 40.5            | 8.5             | 0.21          | 49.0       | USD      |

  Scenario: A mixture of GBP and USD transactions
    Given there are the following charges in Stripe
      | amount | fee | currency | country |
      | 4900   | 638 | usd      | FR      |
      | 2300   | 500 | gbp      | FR      |
    When I run the CSV export for the period
    Then a CSV file should be created with the contents
      | Invoice Number  | Invoice Date | Customer Name | Line Description       | Line Unit Price | Line VAT Amount | Line VAT Rate | Line Gross | Currency |
      | FR-USD-31012019 | 31-01-2019   | Mr FR         | Sales for January 2019 | 40.83           | 8.17            | 0.2           | 49.0       | USD      |
      | FR-GBP-31012019 | 31-01-2019   | Mr FR         | Sales for January 2019 | 19.17           | 3.83            | 0.2           | 23.0       | GBP      |
    And the summary report should read
      """
      Gross amount processed: 49.00 USD, 23.00 GBP
      Total fees paid: 6.38 USD, 5.00 GBP
      """

  Scenario: There are fees from different sources
    Given the following charge exists in Stripe
      | amount | fee | currency | country |
      | 4900   | 500 | usd      | FR      |
    And the fees for the charge are
      | amount | description               | currency |
      | 250    | Stripe processing fees    | usd      |
      | 250    | Some other processing fee | eur      |
    When I run the CSV export for the period
    Then a CSV file should be created with the contents
      | Invoice Number  | Invoice Date | Customer Name | Line Description       | Line Unit Price | Line VAT Amount | Line VAT Rate | Line Gross | Currency |
      | FR-USD-31012019 | 31-01-2019   | Mr FR         | Sales for January 2019 | 40.83           | 8.17            | 0.2           | 49.0       | USD      |
    And the summary report should read
      """
      Gross amount processed: 49.00 USD
      Total fees paid: 5.00 USD

      Fee breakdown:
      Stripe processing fees: 2.50 USD
      Some other processing fee: 2.50 EUR
      """

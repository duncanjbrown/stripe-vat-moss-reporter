# Stripe VAT MOSS Reporter for ClearBooks

This program will pull all transactions for a given calendar month and assign them to the different countries in the EU, 
calculating the VAT rate. It outputs a CSV file suitable for importing into ClearBooks.

It displays all sums in GBP.

## Installation

```
git clone git@github.com:duncanjbrown/stripe-vat-moss-reporter.git
cd stripe-vat-moss-reporter
cp config/stripe.example.yml config/stripe.yml
```

## Configuration

Add your Stripe _secret_ key (eg `sk_live_123456`) to the file `config/stripe.yml`.

To fetch the latest VAT rates, run `rake fetch_vat_rates`. This uses the (great, free) https://euvatrates.com/ webservice.

## Usage 

To generate a report for a given month, pass the month number and year as arguments to the script.

For example, to report the transactions for May 2016, issue

```
./report.rb 05 2016
```

You'll see a progress indicator showing the data being downloaded from Stripe, with some summary figures at the end.

```
$ ./reporter.rb 05 2016
Fetching charge data from Stripe
.......
Gross amount processed: £15000.00
Total fees: £600.00
Processed 572 transactions
```

You will find the full report in `output/stripe-invoices-{date}.csv`. It looks like this:

```
$ column -s, -t < output/stripe-invoices-31-05-2016.csv

Invoice Number  Invoice Date  Customer Name  Line Description        Line Net Price  Line VAT Rate
US31052016      31-05-2016    Mr US          Purchases for May 2016  1234.56         0.0
HU31052016      31-05-2016    Mr HU          Purchases for May 2016  12.34           0.27
GB31052016      31-05-2016    Mr GB          Purchases for May 2016  1234.56         0.2
ROW31052016     31-05-2016    Mr ROW         Purchases for May 2016  1234.56         0.0
IE31052016      31-05-2016    Mr IE          Purchases for May 2016  123.4           0.23
DE31052016      31-05-2016    Mr DE          Purchases for May 2016  12.34           0.19

... etc 
```

A few things to note:

- Each country is assigned a customer name, which is Mr {COUNTRY_CODE}. In non-US or EU countries this name is "Mr ROW".
- The date of the invoices is the end of the specified month.
- Each invoice is assigned a number which is the concatenated country code and date.
- The rates are kept in `data/rates.yml`, and are updated via `rake fetch_vat_rates`.

## Uploading to Clearbooks

You will need to create each of these customers in the ClearBooks admin. The program provides a ready-made CSV to import them.
You can find it at `output/customers.csv`.

Having imported these into ClearBooks, you need to manually visit each country/customer's page to pick "Digital Services to EU Customer" as the default VAT treatment and set the Country field for their default Invoice Address.

Once the customers are created you can simply import the generated `stripe-invoices-{date}` file using the ClearBooks transactions importer.

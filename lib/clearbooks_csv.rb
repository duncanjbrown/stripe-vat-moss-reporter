require 'csv'
require 'yaml'
require 'stripe_charge'

class ClearbooksCsv
  def initialize(stripe_data)
    @stripe_data = stripe_data
    @rates = YAML.load_file('data/rates.yml')
  end

  def clear_books_headers
    [
      'Invoice Number',
      'Invoice Date',
      'Customer Name',
      'Line Description',
      'Line Unit Price',
      'Line VAT Amount',
      'Line VAT Rate',
      'Line Gross',
      'Currency'
    ]
  end

  def generate
    country_data = stripe_data_by_country_and_currency
    clear_books_csv = country_data.map do |country, data|
      country, currency = country.split('_')

      cost_before_vat = get_amount_before_tax(data[:amount], data[:vat_rate])
      row = []
      row << generate_invoice_number(country, currency)
      row << @stripe_data.end_date.strftime('%d-%m-%Y')
      row << generate_client_name(country)
      row << "Sales for #{@stripe_data.start_date.strftime('%B %Y')}"
      row << cost_before_vat
      row << ((data[:amount].to_f / 100) - cost_before_vat).round(2)
      row << (data[:vat_rate].to_f / 100).round(2)
      row << data[:amount].to_f / 100
      row << currency.upcase
    end
    clear_books_csv.unshift clear_books_headers

    CSV.open(filename, 'wb') do |csv|
      clear_books_csv.map { |row| csv << row }
    end
    true
  end

  def summary
    basic = "Gross amount processed: #{totals_by_currency}\n" \
    "Total fees paid: #{fees_by_currency}"

    if fees_by_source
      basic + "\n\nFee breakdown:\n#{fees_by_source}"
    else
      basic
    end
  end

  def filename
    'output/stripe-invoices-' \
      "#{@stripe_data.end_date.strftime('%d-%m-%Y')}.csv"
  end

  def get_amount_before_tax(amount, tax_rate)
    ((amount.to_f / 100) /
      (1 + (tax_rate.to_f / 100)
      )).round(2)
  end

  def fees_by_source
    fee_types = {}
    fee_currencies = {}

    @stripe_data.data.map do |stripe_charge|
      details = stripe_charge[:balance_transaction][:fee_details]
      details&.each do |fee|
        fee_identifier = fee[:description]

        fee_currencies[fee_identifier] ||= fee[:currency]
        fee_types[fee_identifier] ||= 0
        fee_types[fee_identifier] += fee[:amount].to_i
      end
    end

    if fee_types.any?
      fee_types.keys.map do |fee_identifier|
        "#{fee_identifier}: " \
        "#{format('%.2f', fee_types[fee_identifier].to_f / 100)}\ "\
          "#{fee_currencies[fee_identifier].upcase}"
      end.join("\n")
    end
  end

  def fees_by_currency
    fees = {}

    @stripe_data.data.map do |stripe_charge|
      charge = StripeCharge.new(stripe_charge)
      currency = charge.currency
      fees[currency] ||= 0
      fees[currency] += charge.fee
    end

    currency_kvs_to_string_summary(fees)
  end

  def totals_by_currency
    totals = {}

    @stripe_data.data.map do |stripe_charge|
      charge = StripeCharge.new(stripe_charge)
      currency = charge.currency
      totals[currency] ||= 0
      totals[currency] += charge.amount
    end

    currency_kvs_to_string_summary(totals)
  end

  def currency_kvs_to_string_summary(currency_to_amount_pairs)
    currency_to_amount_pairs.keys.map do |currency|
      "#{format('%.2f', currency_to_amount_pairs[currency].to_f / 100)}\ "\
      "#{currency.upcase}"
    end.join(', ')
  end

  def generate_client_name(country)
    "Mr #{country}"
  end

  def generate_invoice_number(country, currency)
    "#{country}-#{currency.upcase}-#{@stripe_data.end_date.strftime('%d%m%Y')}"
  end

  def stripe_data_by_country_and_currency
    output = {}
    @stripe_data.data.map do |charge|
      charge = StripeCharge.new(charge)
      country =  charge.country
      vat_rate = @rates[country]

      # Smush all non-US, non-EU countries into one row
      country = 'ROW' if vat_rate.nil? && (country != 'US')
      country_key = "#{country}_#{charge.currency}"

      output[country_key] ||= { amount: 0, count: 0, vat_rate: 0 }
      output[country_key][:amount] += charge.amount
      output[country_key][:count] += 1
      output[country_key][:vat_rate] = vat_rate || 0
    end

    output
  end
end

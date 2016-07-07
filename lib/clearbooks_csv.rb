require 'csv'
require 'yaml'

class ClearbooksCsv

  def initialize(stripe_data)
    @stripe_data = stripe_data
    @rates = YAML.load_file('data/rates.yml')
  end

  def clear_books_headers
    ["Invoice Number", "Invoice Date", "Customer Name", "Line Description", "Line Unit Price", "Line VAT Amount", "Line VAT Rate", "Line Gross"]
  end

  def generate
    data = stripe_data_by_country
    clear_books_csv = data.map do |country, data|
      cost_before_vat = get_amount_before_tax(data[:amount], data[:vat_rate])
      clear_books_row = []
      clear_books_row << generate_invoice_number(country)
      clear_books_row << @stripe_data.end_date.strftime("%d-%m-%Y")
      clear_books_row << generate_client_name(country)
      clear_books_row << "Sales for #{@stripe_data.start_date.strftime("%B %Y")}"
      clear_books_row << cost_before_vat
      clear_books_row << ((data[:amount].to_f / 100) - cost_before_vat).round(2)
      clear_books_row << (data[:vat_rate].to_f / 100).round(2)
      clear_books_row << data[:amount].to_f / 100
    end
    clear_books_csv.unshift clear_books_headers
    clear_books_csv
    CSV.open("output/stripe-invoices-#{@stripe_data.end_date.strftime("%d-%m-%Y")}.csv", "wb") do |csv|
      clear_books_csv.map { |row| csv << row }
    end
    true
  end

  def get_amount_before_tax(amount, tax_rate)
    ((amount.to_f / 100) / 
      (1 + ( tax_rate.to_f / 100 )
    )).round(2)
  end

  def fees
    fees = 0
    @stripe_data.data.map do |stripe_charge|
      fees += stripe_charge.balance_transaction.fee
    end
    fees
  end

  def total 
    total = 0
    @stripe_data.data.map do |stripe_charge|
      total += stripe_charge.balance_transaction[:amount]
    end 
    total 
  end

  def generate_client_name(country)
    "Mr #{country}"
  end

  def generate_invoice_number(country)
    "#{country}#{@stripe_data.end_date.strftime("%d%m%Y")}"
  end

  def stripe_data_by_country
    output = {}
    @stripe_data.data.map do |charge|
      country = charge[:source][:country]
      vat_rate = @rates[country]

      # Smush all non-US, non-EU countries into one row
      if vat_rate.nil? and country != "US"
        country = "ROW"
      end

      begin
        output[country] ||= {amount: 0, count: 0, vat_rate: 0}
        output[country][:amount] += charge.balance_transaction[:amount]
        output[country][:count] += 1
        output[country][:vat_rate] = vat_rate || 0
      rescue Exception => e
        raise charge.inspect
      end
    end

    output
  end


end

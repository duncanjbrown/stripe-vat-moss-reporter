require 'csv'
require 'yaml'

class ClearbooksCsv

  def initialize(stripe_data)
    @stripe_data = stripe_data
    @rates = YAML.load_file('data/rates.yml')
  end

  def clear_books_headers
    ["Invoice Number", "Invoice Date", "Customer Name", "Line Description", "Line Net Price", "Line VAT Rate"]
  end

  def generate
    data = stripe_data_by_country
    clear_books_csv = data.map do |country, data|
      clear_books_row = []
      clear_books_row << generate_invoice_number(country)
      clear_books_row << @stripe_data.end_date.strftime("%d-%m-%Y")
      clear_books_row << generate_client_name(country)
      clear_books_row << "Subscriptions for #{@stripe_data.start_date.strftime("%B %Y")}"
      clear_books_row << data[:amount]
      clear_books_row << data[:vat_rate]
    end
    clear_books_csv.unshift clear_books_headers
    clear_books_csv
    CSV.open("output/stripe-invoices-#{@stripe_data.end_date.strftime("%d-%m-%Y")}.csv", "wb") do |csv|
      clear_books_csv.map { |row| csv << row }
    end
    true
  end

  def generate_client_name(country)
    "Mr #{country}"
  end

  def generate_invoice_number(country)
    "Stripe-#{country}_#{@stripe_data.end_date.strftime("%d-%m-%Y")}"
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

    	output[country] ||= {amount: 0, count: 0, vat_rate: 0}
    	output[country][:amount] += charge[:amount]
    	output[country][:count] += 1
    	output[country][:vat_rate] = vat_rate || 0
    end
    output
  end


end

#!/usr/bin/env ruby

require 'csv'
require 'stripe'
require 'active_support/all' 
require 'yaml'

thing = YAML.load_file('data/rates.yml')
puts thing.inspect

exit

Stripe.api_key = "sk_test_cuWwUeGTSSkVqZNQFtkz96cW"

# also get charge statement from all transfers over the course of this period

def get_charges(starting_after = nil)
	charges = Stripe::Charge.all(
		created: { 
			gte: DateTime.parse('1st April 2016').to_time.to_i, 
			lte: DateTime.parse('1st April 2016').end_of_month.to_time.to_i
		}, 
		limit: 2,
		starting_after: starting_after
	)
	
	if charges.has_more
		return charges.data.concat get_charges(charges.data.last.id)
	else
		return charges.data
	end
end


valid_charges = get_charges.reject { |c| c[:status] != "succeeded" }

output = {}
data = valid_charges.map do |charge|
	country = charge[:source][:country]
	output[country] ||= {amount: 0, count: 0}
	output[country][:amount] += charge[:amount]
	output[country][:count] += 1
end

for_csv = output.map { |k, v| [k].concat v.values }

CSV.open("out.csv", "wb") do |csv|
	csv << ["Country", "Total Amount", "Charges"]
	for_csv.map { |r| csv << r }
end




#!/usr/bin/env ruby

require 'active_support/all'
require './lib/stripe_data'
require './lib/clearbooks_csv'
require './lib/clearbooks_clients'

month = ARGV[0].to_s || Time.now.month
year = ARGV[1].to_s || Time.now.year

Stripe.api_key = YAML.load_file('config/stripe.yml')["key"]

ClearbooksClients.new.generate

puts "\n"
puts "Fetching charge data from Stripe"

stripe_data = StripeData.new(month, year)
clearbooks_csv = ClearbooksCsv.new(stripe_data)

clearbooks_csv.generate
fees = clearbooks_csv.fees
total = clearbooks_csv.total

puts "\n\n"
puts "Gross amount processed: £#{total.to_f / 100}"
puts "Total fees paid to Stripe: £#{fees.to_f / 100}"
puts "Processed #{stripe_data.data.count} transactions"
puts "\n"

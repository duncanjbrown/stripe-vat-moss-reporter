#!/usr/bin/env ruby

require 'active_support/all'

$LOAD_PATH.unshift File.expand_path(".", "lib")

require 'stripe_data'
require 'clearbooks_csv'
require 'clearbooks_clients'
require 'stripe_charge'

month = ARGV[0].to_s || Time.now.month
year = ARGV[1].to_s || Time.now.year

Stripe.api_key = YAML.load_file('config/stripe.yml')['key']

ClearbooksClients.new.generate

puts "\n"
puts 'Fetching charge data from Stripe'

stripe_data = StripeData.new(month, year)
clearbooks_csv = ClearbooksCsv.new(stripe_data)

clearbooks_csv.generate
puts clearbooks_csv.summary

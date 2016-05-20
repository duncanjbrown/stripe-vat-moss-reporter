#!/usr/bin/env ruby

require 'active_support/all'
require './lib/stripe_data'
require './lib/clearbooks_csv'
require './lib/clearbooks_clients'

Stripe.api_key = "sk_test_cuWwUeGTSSkVqZNQFtkz96cW"

#stripe_data = StripeData.new("04", "2016")
#clearbooks_csv = ClearbooksCsv.new(stripe_data)
clearbooks_clients = ClearbooksClients.new

clearbooks_clients.generate
#clearbooks_csv.generate

puts "Done!"

# also get charge statement from all transfers over the course of this period

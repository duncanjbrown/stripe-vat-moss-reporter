#!/usr/bin/env ruby

require 'active_support/all'
require './lib/stripe_data'
require './lib/clearbooks_csv'
require './lib/clearbooks_clients'

Stripe.api_key = YAML.load('config/stripe.yml')[:key]

ClearbooksClients.new.generate

stripe_data = StripeData.new("04", "2016")
clearbooks_csv = ClearbooksCsv.new(stripe_data).generate

puts "Processed #{stripe_data.data.count} transactions"

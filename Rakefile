task :fetch_vat_rates do
  require 'open-uri'
  require 'json'
  require 'yaml'

  json = open('https://euvatrates.com/rates.json').read
  rates = JSON.parse(json)
  tuples = rates["rates"].map do |(country, values)|
    [country, values["standard_rate"]] 
  end

  File.open('data/rates.yml', 'w') do |f|
    tuples.map do |(country, rate)|
      f.puts "#{country}: #{rate.to_i}"
    end
  end

  puts 'VAT rates updated'
end

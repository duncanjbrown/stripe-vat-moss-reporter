task :fetch_vat_rates do
  require 'open-uri'
  require 'json'
  require 'yaml'

  vatlayer_key = ENV.fetch('VATLAYER_ACCESS_KEY')

  json = open("http://www.apilayer.net/api/rate_list?access_key=#{vatlayer_key}").read
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

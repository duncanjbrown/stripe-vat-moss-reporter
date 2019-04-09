require 'csv'
require 'yaml'

class ClearbooksClients
  def initialize
    @countries = YAML.load_file('data/rates.yml').keys
  end

  def generate
    CSV.open('output/clients.csv', 'wb') do |csv|
      csv << %w[Customer Country]
      @countries.map do |country|
        csv << [generate_client_name(country), country]
      end
      csv << ['Mr US', 'US']
      csv << ['Mr ROW', nil]
    end
  end

  def generate_client_name(country)
    "Mr #{country}"
  end
end

require 'csv'
require 'yaml'

class ClearbooksClients

  def initialize
    @countries = YAML.load_file('data/rates.yml').keys
  end

  def generate
    CSV.open("output/clients.csv", "wb") do |csv|
      csv << ["Customer"]
      @countries.map do |country|
        csv << [generate_client_name(country)]
      end
      csv << ["Mr US"]
      csv << ["Mr ROW"]
    end
  end

  def generate_client_name(country)
    "Mr #{country}"
  end

end

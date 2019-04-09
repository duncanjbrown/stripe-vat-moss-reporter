require 'spec_helper'
require 'clearbooks_csv'

RSpec.describe ClearbooksCsv do
  let(:stripe_data) do
    Struct.new(:data, :start_date, :end_date).new(
      [{
        "balance_transaction": { "amount": 4900, "fee": 638 },
        "currency": 'usd',
        "source": { "country": 'FR' }
      }], Date.new(2019, 1, 1), Date.new(2019, 1, 31)
    )
  end

  subject(:clearbooks_csv) { ClearbooksCsv.new(stripe_data) }

  describe '#generate_csv' do
    it 'returns CSV with a row for each country' do
      output = clearbooks_csv.generate
      puts output.inspect
      parsed = CSV.parse(output, headers: :first_row).map(&:to_h)
      puts parsed.inspect
    end
  end
end

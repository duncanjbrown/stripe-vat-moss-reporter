require 'clearbooks_csv'

module CSVGenerationHelper
  def create_stripe_charges(hashes)
    @stripe_charges = Struct.new(:data, :start_date, :end_date).new(
      hashes.map do |h|
        {
          "balance_transaction": { "amount": h[:amount], "fee": h[:fee] },
          "currency": h[:currency],
          "source": { "country": h[:country] }
        }
      end, Date.new(2019, 1, 1), Date.new(2019, 1, 31)
    )
  end
end

World(CSVGenerationHelper)

Given('there are the following charges in Stripe') do |table|
  create_stripe_charges(table.hashes)
end

When('I run the CSV export for the period') do
  ClearbooksCsv.new(@stripe_charges).generate
end

Then('a CSV file should be created with the contents') do |table|
  csv_contents = CSV.open(ClearbooksCsv.new(@stripe_charges).filename,
                          headers: true).map(&:to_h)

  expect(table.hashes).to match(csv_contents)
end

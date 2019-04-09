require 'clearbooks_csv'

module CSVGenerationHelper
  def get_stripe_charges
    Struct.new(:data, :start_date, :end_date).new(
      @stripe_charges, Date.new(2019, 1, 1), Date.new(2019, 1, 31)
    )
  end

  def add_stripe_charge(row)
    @stripe_charges ||= []
    @stripe_charges << row_to_stripe_hash(row)
  end

  def update_last_stripe_charge
    @stripe_charges << yield(@stripe_charges.pop)
  end

  def row_to_stripe_hash(row)
    {
      "balance_transaction": {
        "amount": row[:amount], "fee": row[:fee], "currency": row[:currency]
      },
      "source": { "country": row[:country] }
    }
  end
end

World(CSVGenerationHelper)

Given('there are the following charges in Stripe') do |table|
  table.hashes.map { |row| add_stripe_charge(row) }
end

When('I run the CSV export for the period') do
  @export = ClearbooksCsv.new(get_stripe_charges)
  @export.generate
end

Then('a CSV file should be created with the contents') do |table|
  csv_contents = CSV.open(ClearbooksCsv.new(get_stripe_charges).filename,
                          headers: true).map(&:to_h)

  expect(table.hashes).to match(csv_contents)
end

Then('the summary report should read') do |summary|
  expect(@export.summary).to eq(summary)
end


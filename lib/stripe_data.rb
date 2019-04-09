require 'stripe'

class StripeData
  attr_accessor :data
  attr_accessor :start_date
  attr_accessor :end_date

  def initialize(month, year)
    @start_date = DateTime.strptime("#{month}-#{year}", '%m-%Y')
    @end_date = @start_date.end_of_month
    @data = get_charges
  end

  def get_charges(starting_after = nil)
    print '.'
    charges = Stripe::Charge.all(
      created: {
        gte: @start_date.to_time.to_i,
        lte: @end_date.to_time.to_i
      },
      limit: 100,
      starting_after: starting_after,
      expand: ['data.balance_transaction']
    )

    data = charges.select(&:paid)

    if charges.has_more
      data.concat get_charges(charges.data.last.id)
    else
      data
    end
  end
end

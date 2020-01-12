class StripeCharge
  def initialize(charge)
    @charge = charge
  end

  def country
    if charge[:source]
      charge[:source][:country]
    else
      charge[:payment_method_details][:card][:country]
    end
  end

  def currency
    charge[:balance_transaction][:currency]
  end

  def amount
    charge[:balance_transaction][:amount].to_i
  end

  def fee
    charge[:balance_transaction][:fee].to_i
  end

private

  attr_reader :charge
end

class StripeCharge
  def initialize(charge)
    @charge = charge
  end

  def country
    charge.dig(:source, :country)
  end

  def currency
    charge.dig(:balance_transaction, :currency)
  end

  def amount
    charge.dig(:balance_transaction, :amount).to_i
  end

  def fee
    charge.dig(:balance_transaction, :fee).to_i
  end

private

  attr_reader :charge
end

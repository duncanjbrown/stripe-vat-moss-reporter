require 'spec_helper'
require 'stripe_charge'

RSpec.describe StripeCharge do
  subject(:charge) { StripeCharge.new(stripe_data) }
  let(:stripe_data) { default_stripe_data }
  let(:default_stripe_data) do
    {
      "amount": 3400,
      "balance_transaction": { "id": 'txn_GKrvHklCLSjN1y', "object": 'balance_transaction', "amount": 3400, "available_on": 1_576_540_800, "created": 1_575_997_645, "currency": 'usd', "description": 'Invoice 077A2E8-0004', "exchange_rate": nil, "fee": 452, "fee_details": [{ "amount": 112, "application": nil, "currency": 'usd', "description": 'Stripe processing fees', "type": 'stripe_fee' }, { "amount": 340, "application": 'ca_B6EDHxKm1bURBg1CCMk0YBdAhWK3TVyP', "currency": 'usd', "description": 'Substack application fee', "type": 'application_fee' }], "net": 2948, "reporting_category": 'charge', "source": 'ch_GKrvQK8ERJUHzU', "sourced_transfers": { "object": 'list', "data": [], "has_more": false, "total_count": 0, "url": '/v1/transfers?source_transaction=ch_GKrvQK8ERJUHzU' }, "status": 'available', "type": 'charge' },
      "billing_details": { "address": { "city": nil, "country": nil, "line1": nil, "line2": nil, "postal_code": '33418', "state": nil }, "email": nil, "name": nil, "phone": nil },
      "currency": 'usd',
      "fraud_details": {},
      "payment_method_details": { "card": { "brand": 'visa', "checks": { "address_line1_check": nil, "address_postal_code_check": 'pass', "cvc_check": nil }, "country": 'US', "exp_month": 7, "exp_year": 2022, "fingerprint": 'blah', "funding": 'credit', "installments": nil, "last4": '1234', "network": 'visa', "three_d_secure": nil, "wallet": nil }, "type": 'card' },
      "source": { "id": 'card_DX2Gf9nqciEWm8', "object": 'card', "address_city": nil, "address_country": nil, "address_line1": nil, "address_line1_check": nil, "address_line2": nil, "address_state": nil, "address_zip": '33418', "address_zip_check": 'pass', "brand": 'Visa', "country": 'US', "customer": 'cus_31AcIC6FJn5qS0', "cvc_check": nil, "dynamic_last4": nil, "exp_month": 7, "exp_year": 2022, "fingerprint": '5rdq1ECjPoW4Fx62', "funding": 'credit', "last4": '6863', "metadata": {}, "name": nil, "tokenization_method": nil },
      "status": 'succeeded'
    }
  end

  context 'a charge with fields in the expected places' do
    it 'returns the correct values' do
      expect(charge.country).to eq 'US'
      expect(charge.currency).to eq 'usd'
      expect(charge.amount).to eq 3400
      expect(charge.fee).to eq 452
    end
  end

  context 'a charge without a "source"' do
    let(:stripe_data) { default_stripe_data.merge(source: nil) }

    it 'returns the correct values' do
      expect(charge.country).to eq 'US'
      expect(charge.currency).to eq 'usd'
      expect(charge.amount).to eq 3400
      expect(charge.fee).to eq 452
    end
  end
end

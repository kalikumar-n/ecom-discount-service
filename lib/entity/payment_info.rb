# frozen_string_literal: true

class PaymentInfo
  attr_accessor :method, :bank_name, :card_type

  def initialize(method:, bank_name: nil, card_type: nil)
    @method = method
    @bank_name = bank_name
    @card_type = card_type
  end

  def credit_card?
    method == 'credit_card'
  end

  def debit_card?
    method == 'debit_card'
  end

  def bank_transfer?
    method == 'bank_transfer'
  end
end 
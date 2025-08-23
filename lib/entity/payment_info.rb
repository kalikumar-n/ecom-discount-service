# frozen_string_literal: true

class PaymentInfo
  attr_accessor :method, :bank_name, :card_type

  def initialize(method:, bank_name: nil, card_type: nil, card_brand: nil)
    @method = method
    @bank_name = bank_name
    @card_type = card_type
    @card_brand = card_brand
  end

  def upi_payment?
    method == PaymentMethod::UPI
  end

  def card_payment?
    method == PaymentMethod::CARD
  end

  def bank_transfer?
    method == PaymentMethod::BANK_TRANSFER
  end

  def credit_card?
    card_type == CardType::CREDIT_CARD
  end

  def debit_card?
    card_type == CardType::DEBIT_CARD
  end
end 
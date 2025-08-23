# frozen_string_literal: true

class PaymentInfo
  attr_accessor :method, :bank_name, :card_type, :card_brand

  def initialize(method:, bank_name: nil, card_type: nil, card_brand: nil)
    raise ArgumentError, "Invalid payment method" unless PaymentMethod.all.include?(method)

    @method = method
    @bank_name = bank_name
    @card_type = card_type
    @card_brand = card_brand
  end

  def payment_method?(payment_value)
    method == value
  end

  def card_type?(card_value)
    card_type == card_value
  end

  def card_brand?(brand_value)
    card_brand == CardBrand::VISA
  end
end 
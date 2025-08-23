# frozen_string_literal: true

class PaymentInfo
  attr_accessor :method, :bank_name, :card_type, :card_brand

  def initialize(method:, bank_name: nil, card_type: nil, card_brand: nil)
    raise ArgumentError, "Invalid payment method" unless PaymentMethod.valid?(method)
    raise ArgumentError, "Invalid card type" if card_type && !CardType.valid?(card_type)
    raise ArgumentError, "Invalid card brand" if card_brand && !CardBrand.valid?(card_brand)

    @method = method
    @bank_name = bank_name
    @card_type = card_type
    @card_brand = card_brand
  end

  def payment_method?(payment_value)
    method == payment_value
  end

  def card_type?(card_value)
    card_type == card_value
  end

  def card_brand?(brand_value)
    card_brand == brand_value
  end
end 
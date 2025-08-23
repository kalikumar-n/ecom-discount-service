# frozen_string_literal: true

class DiscountedPrice
  attr_accessor :original_price, :final_price, :applied_discounts, :message

  def initialize(original_price:, final_price:, applied_discounts: {}, message: '')
    @original_price = original_price
    @final_price = final_price
    @applied_discounts = applied_discounts
    @message = message
  end

  def total_discount
    original_price - final_price
  end

  def discount_percentage
    return 0 if original_price.zero?
    ((total_discount / original_price) * 100).round(2)
  end
end 
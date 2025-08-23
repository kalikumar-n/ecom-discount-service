# frozen_string_literal: true

class DiscountedPrice
  attr_accessor :original_price, :final_price, :applied_discounts, :message

  def initialize(original_price:, final_price:, applied_discounts: {}, message: '')
    raise ArgumentError, 'original_price must be numeric' unless original_price.is_a?(Numeric)
    raise ArgumentError, 'final_price must be numeric' unless final_price.is_a?(Numeric)
    if final_price > original_price
      raise ArgumentError, 'final_price cannot exceed original_price'
    end
    
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

  def print_details
    <<~DETAILS
      1. DiscountedPrice(original: #{original_price})
      2. final: #{final_price}
      3. discount: #{total_discount}
      4. percent: #{discount_percentage}%)
    DETAILS
  end
  
end 
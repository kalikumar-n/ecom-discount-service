# frozen_string_literal: true
require 'bigdecimal'

class DiscountedPrice
  attr_reader :original_price, :final_price, :applied_discounts, :message

  def initialize(original_price:, final_price:, applied_discounts: {}, message: '')
    raise ArgumentError, 'original_price must be numeric' unless original_price.is_a?(Numeric)
    raise ArgumentError, 'final_price must be numeric' unless final_price.is_a?(Numeric)
    
    # Ensure discounting logic is valid (no price inflation by mistake)
    if final_price > original_price
      raise ArgumentError, 'final_price cannot exceed original_price'
    end
    
    @original_price = original_price
    @final_price = final_price
    @applied_discounts = applied_discounts
    @message = message
  end

  # Returns the absolute discount amount
  def total_discount
    original_price - final_price
  end

  # Returns discount as a percentage of the original price
  def discount_percentage
    return 0 if original_price.zero?
    ((total_discount / original_price) * 100).round(2)
  end

  # Pretty-prints price and discount details in a readable format
  def print_details
    <<~DETAILS
      1. Original Price: #{format_price(original_price)}
      2. final: #{format_price(final_price)}
      3. discount: #{format_price(total_discount)}
      4. percent: #{format_price(discount_percentage)}%
      5. Applied Discounts: #{formated_discounts.map { |k, v| "#{k}: #{v}" }.join(", ")}
    DETAILS
  end

  def format_price(price)
    BigDecimal(price).to_s('F')
  end
  
  def formated_discounts
    @applied_discounts.transform_values { |price| format_price(price) }
  end
end 
# frozen_string_literal: true

require_relative 'entity/customer_profile'
require_relative 'entity/cart_item'
require_relative 'entity/product'
require_relative 'entity/payment_info'
require_relative 'entity/discounted_price'
require_relative 'enum/brand_tier'
require_relative 'exceptions/discount_calculation_exception'
require_relative 'exceptions/discount_validation_exception'

class DiscountService
  # Valid coupon codes
  VALID_COUPON_CODES = {
    'SAVE10' => 0.10,    # 10% discount
    'SAVE20' => 0.20,    # 20% discount
    'SAVE30' => 0.30,    # 30% discount
    'FLAT50' => 50.0     # $50 flat discount
  }.freeze

  # Brand tier discounts
  BRAND_DISCOUNTS = {
    BrandTier::PREMIUM => 0.15,  # 15% discount for premium brands
    BrandTier::REGULAR => 0.10,  # 10% discount for regular brands
    BrandTier::BUDGET => 0.05    # 5% discount for budget brands
  }.freeze

  # Category discounts
  CATEGORY_DISCOUNTS = {
    'electronics' => 0.12,   # 12% discount for electronics
    'clothing' => 0.08,      # 8% discount for clothing
    'books' => 0.15,         # 15% discount for books
    'home' => 0.10           # 10% discount for home goods
  }.freeze

  # Bank-specific discounts
  BANK_DISCOUNTS = {
    'Chase' => 0.05,         # 5% discount for Chase cards
    'Bank of America' => 0.03, # 3% discount for BoA cards
    'Wells Fargo' => 0.04    # 4% discount for Wells Fargo cards
  }.freeze

  def self.calculate_cart_discounts(cart_items:, customer:, payment_info: nil, coupon_code: nil)
    begin
      # Calculate original cart price
      original_price = calculate_original_price(cart_items)
      current_price = original_price
      applied_discounts = {}
      messages = []

      # Apply brand discounts first
      brand_discount = apply_brand_discounts(cart_items, current_price)
      if brand_discount > 0
        current_price -= brand_discount
        applied_discounts['Brand Discount'] = brand_discount
        messages << "Applied brand tier discount: $#{brand_discount.round(2)}"
      end

      # Apply category discounts
      category_discount = apply_category_discounts(cart_items, current_price)
      if category_discount > 0
        current_price -= category_discount
        applied_discounts['Category Discount'] = category_discount
        messages << "Applied category discount: $#{category_discount.round(2)}"
      end

      # Apply coupon discount if valid
      if coupon_code && validate_discount_code(code: coupon_code, cart_items: cart_items, customer: customer)
        coupon_discount = apply_coupon_discount(coupon_code, current_price)
        if coupon_discount > 0
          current_price -= coupon_discount
          applied_discounts['Coupon Discount'] = coupon_discount
          messages << "Applied coupon discount: $#{coupon_discount.round(2)}"
        end
      end

      # Apply bank discount if applicable
      if payment_info && payment_info.bank_name
        bank_discount = apply_bank_discount(payment_info, current_price)
        if bank_discount > 0
          current_price -= bank_discount
          applied_discounts['Bank Discount'] = bank_discount
          messages << "Applied bank discount: $#{bank_discount.round(2)}"
        end
      end

      # Ensure final price doesn't go below zero
      current_price = [current_price, 0].max

      DiscountedPrice.new(
        original_price: original_price,
        final_price: current_price,
        applied_discounts: applied_discounts,
        message: messages.join('; ')
      )

    rescue StandardError => e
      raise DiscountCalculationException.new("Failed to calculate cart discounts: #{e.message}", e)
    end
  end

  def self.validate_discount_code(code:, cart_items:, customer:)
    VALID_COUPON_CODES.key?(code.upcase)
  end

  private

  def self.calculate_original_price(cart_items)
    cart_items.sum(&:total_price)
  end

  def self.apply_brand_discounts(cart_items, current_price)
    total_brand_discount = 0

    cart_items.each do |item|
      brand_tier = item.product.brandtier
      discount_rate = BRAND_DISCOUNTS[brand_tier] || 0
      item_discount = item.total_price * discount_rate
      total_brand_discount += item_discount
    end

    total_brand_discount
  end

  def self.apply_category_discounts(cart_items, current_price)
    total_category_discount = 0

    cart_items.each do |item|
      category = item.product.category.downcase
      discount_rate = CATEGORY_DISCOUNTS[category] || 0
      item_discount = item.total_price * discount_rate
      total_category_discount += item_discount
    end

    total_category_discount
  end

  def self.apply_coupon_discount(coupon_code, current_price)
    discount_value = VALID_COUPON_CODES[coupon_code.upcase]
    return 0 unless discount_value

    if discount_value <= 1.0
      # Percentage discount
      current_price * discount_value
    else
      # Flat amount discount
      [discount_value, current_price].min
    end
  end

  def self.apply_bank_discount(payment_info, current_price)
    return 0 unless payment_info.bank_name

    bank_name = payment_info.bank_name
    discount_rate = BANK_DISCOUNTS[bank_name] || 0
    current_price * discount_rate
  end
end 
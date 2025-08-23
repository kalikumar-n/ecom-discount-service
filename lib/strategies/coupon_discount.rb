require_relative 'base_discount'
require_relative '../enum/customer_tier'  # <-- add this line

class CouponDiscount < BaseDiscount

  #Defines available vouchers and their rules.
  # Each voucher can restrict by:
  # - excluded brands
  # - allowed categories
  # - required customer tiers
  VOUCHERS = {
    'SUPER69' => {
      amount: 69, 
      excluded_brands: ['NIKE'],
      allowed_categories: ['clothing', 'shoes', 'electronics'],
      required_customer_tier: [CustomerTier::GOLD, CustomerTier::SILVER]
    },
    'WELCOME10' => {
      amount: 10, 
      excluded_brands: [],
      allowed_categories: [],
      required_customer_tier: []
    }
  }.freeze

  # Applies coupon discount if all voucher conditions are satisfied.
  def apply(cart_items:, current_price:, **kwargs)
    coupon_code = kwargs[:coupon_code]
    customer = kwargs[:customer]
    voucher = VOUCHERS[coupon_code]
    return { final_price: current_price, applied_discounts: {} } unless voucher

    return { final_price: current_price, applied_discounts: {} } unless valid_for_customer?(voucher, customer)
    return { final_price: current_price, applied_discounts: {} } unless valid_for_cart?(voucher, cart_items)

    discount_amount = [voucher[:amount], current_price].min.round(2) 
    final_price = current_price - discount_amount

    {
      final_price: final_price,
      applied_discounts: { "Coupon: #{coupon_code}" => discount_amount }
    }  
  end

  private

  # Checks if customer tier is eligible for this voucher
  def valid_for_customer?(voucher, customer)
    if voucher[:required_customer_tier].any?
      voucher[:required_customer_tier].include?(customer.tier)
    else
      true
    end 
  end

  # Validates brand/category restrictions for cart items
  def valid_for_cart?(voucher, cart_items)
    cart_items.all? do |item|
      # Reject if item’s brand is explicitly excluded
      return false if voucher[:excluded_brands].include?(item.product.brand.upcase)

      # If categories are restricted, item must match at least one
      if voucher[:allowed_categories].any?
        voucher[:allowed_categories].map(&:downcase).include?(item.product.category.downcase)
      else
        true
      end
    end
  end

end
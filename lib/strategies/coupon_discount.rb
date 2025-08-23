require_relative 'base_discount'

class CouponDiscount < BaseDiscount
  VOUCHERS = {
    'SUPER69' => {
      amount: 69, # amount 69 will be applied as instance discount
      excluded_brands: ['NIKE'],
      allowed_categories: ['clothing', 'shoes'],
      required_customer_tier: [CustomerTier::GOLD, CustomerTier::SILVER]
    },
    'WELCOME10' => {
      amount: 10, # amount 69 will be applied as instance discount
      excluded_brands: [],
      allowed_categories: [],
      required_customer_tier: []
    }
  }.freeze


  def apply(cart_items:, current_price:, **kwargs)
    coupon_code = kwargs[:coupon_code]
    customer = kwargs[:customer]
    voucher = VOUCHERS[coupon_code]
    return { final_price: current_price, applied_discounts: {} } unless voucher

    return { final_price: current_price, applied_discounts: {} } unless valid_for_customer?(voucher, customer)
    return { final_price: current_price, applied_discounts: {} } unless valid_for_cart?(voucher, cart_items)

    discount_amount = voucher[:amount].round(2)
    final_price = current_price - discount_amount
    {
      final_price: final_price,
      applied_discounts: { "Coupon: #{coupon_code}" => discount_amount }
    }  
  end

  private

  def valid_for_customer?(voucher, customer)
    voucher[:required_customer_tier].include? customer.tier
  end

  def valid_for_cart?(voucher, cart_items)
    cart_items.all? do |item|
      # brand exclusion
      return false if voucher[:excluded_brands].include?(item.product.brand.upcase)

      # category restriction (if present, at least one must match)
      if voucher[:allowed_categories].any?
        voucher[:allowed_categories].map(&:downcase).include?(item.product.category.downcase)
      end
    end
  end

end
require 'bigdecimal/util'
require_relative 'strategies/bank_discount'
require_relative 'strategies/category_discount'
require_relative 'strategies/coupon_discount'
require_relative 'strategies/brand_discount'
require_relative 'entity/cart_item'

class DiscountService
  def initialize(strategies = default_strategies)
    @strategies = strategies
  end

  def calculate_cart_discounts(cart_items:, customer:, payment_info: nil, coupon_code: nil)
    begin
      original_price = calculate_original_price(cart_items)
      current_price = original_price
      applied_discounts = {}

      @strategies.each do |strategy|
        result = strategy.apply(
          cart_items: cart_items,
          current_price: current_price,
          payment_info: payment_info,
          coupon_code: coupon_code,
          customer: customer
        )

        discount_amount = result[:applied_discounts].values.sum.to_d

        current_price = result[:final_price].to_d
        raise "Final price must not be negative" if current_price < 0

        result[:applied_discounts].each do |name, amount|
          applied_discounts[name] ||= 0.to_d
          applied_discounts[name] += amount.to_d
        end
      end

      current_price = [current_price, 0.to_d].max

      DiscountedPrice.new(
        original_price: original_price.to_d,
        final_price: current_price,
        applied_discounts: applied_discounts,
        message: "Discounts applied successfully"
      )
    rescue StandardError => e
      raise DiscountCalculationException.new("Error Occurred: #{e.message}", e)
    end
  end

  private

  def calculate_original_price(cart_items)
    cart_items.sum(&:total_price)
  end

  def default_strategies
    [
      BrandDiscount.new,
      CategoryDiscount.new,
      CouponDiscount.new,
      BankDiscount.new
    ]
  end
end
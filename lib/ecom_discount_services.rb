# frozen_string_literal: true

# Main entry point for the ecommerce discount services
require_relative 'entity/customer_profile'
require_relative 'entity/product'
require_relative 'entity/cart_item'
require_relative 'entity/payment_info'
require_relative 'entity/discounted_price'

require_relative 'enum/brand_tier'
require_relative 'enum/card_brand'
require_relative 'enum/card_type'
require_relative 'enum/customer_tier'
require_relative 'enum/payment_method'

require_relative 'exceptions/discount_calculation_exception'
require_relative 'exceptions/discount_validation_exception'

require_relative 'strategies/bank_discount'
require_relative 'strategies/brand_discount'
require_relative 'strategies/category_discount'
require_relative 'strategies/coupon_discount'

require_relative 'discount_service'

module EcomDiscountServices
  VERSION = '1.0.0'
end 
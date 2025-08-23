# frozen_string_literal: true

# Main entry point for the ecommerce discount services
require_relative 'enum/brand_tier'
require_relative 'entity/customer_profile'
require_relative 'entity/product'
require_relative 'entity/cart_item'
require_relative 'entity/payment_info'
require_relative 'entity/discounted_price'
require_relative 'exceptions/discount_calculation_exception'
require_relative 'exceptions/discount_validation_exception'
require_relative 'discount_service'

module EcomDiscountServices
  VERSION = '1.0.0'
end 
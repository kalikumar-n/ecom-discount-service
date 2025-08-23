require_relative 'base_discount'
require 'bigdecimal'
class BankDiscount < BaseDiscount

  BANK_DISCOUNTS = {
    'ICICI' => BigDecimal('0.05'), # 5% discount for ICICI Bank
    'AXIS' => BigDecimal('0.03'), # 3% discount for Axis Bank
    'HDFC' =>BigDecimal('0.04')  # 4% discount for HDFC Bank
  }.freeze


  def apply(cart_items:, current_price:, **kwargs)
    discount_amount = 0

    # Look up discount rate based on bank name, default to 0 if not eligible
    payment_info = kwargs[:payment_info]
    rate = BANK_DISCOUNTS[payment_info&.bank_name&.upcase] || 0
    discount_amount = (current_price * rate).round(2)
    final_price = current_price - discount_amount

    { final_price: final_price, applied_discounts: { 'Bank Discount' => discount_amount } }
  end
end
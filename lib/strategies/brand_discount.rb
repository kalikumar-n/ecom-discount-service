require_relative 'base_discount'

class BrandDiscount < BaseDiscount

  BRANDS = {
    'puma' => 0.40,  # 40% discount for puma brand
    'adidas' => 0.15,  # 15% discount for adidas brand
    'nike' => 0.25   # 25% discount for nike brand
  }.freeze

  def apply(cart_items:, current_price:, **)
    discount_amount = 0.0

    cart_items.each do |item|
      brand = item.product.brand
      discount_rate = BRANDS[brand.downcase] || 0
      item_discount = item.total_price * discount_rate
      discount_amount += item_discount
    end
    final_price = current_price - discount_amount

    { final_price: final_price, applied_discounts: { 'Brand Discount' => discount_amount } }
  end
end

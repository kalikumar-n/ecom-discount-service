require_relative 'base_discount'

class CategoryDiscount < BaseDiscount

  CATEGORY_DISCOUNTS = {
    'electronics' => 0.15,   # 15% discount for electronics products
    'clothing' => 0.10,      # 10% discount for clothing
    'books' => 0.08,         # 8% discount for books
    'home' => 0.05           # 5% discount for home goods
  }.freeze

  def apply(cart_items:, current_price:, **)
    discount_amount = 0

    cart_items.each do |item|
      category = item.product.category
      discount_rate = CATEGORY_DISCOUNTS[category.downcase] || 0
      item_discount = item.total_price * discount_rate
      discount_amount += item_discount
    end
    final_price = current_price - discount_amount

    { final_price: final_price, applied_discounts: { 'Category Discount' => discount_amount } }
  end
end
# frozen_string_literal: true

class CartItem
  attr_accessor :product, :quantity, :size

  def initialize(product:, quantity:, size: nil)
    @product = product
    @quantity = quantity
    @size = size
  end

  def total_price
    product.current_price * quantity
  end

  def total_base_price
    product.base_price * quantity
  end
end 
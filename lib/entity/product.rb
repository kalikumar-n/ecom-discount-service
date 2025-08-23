# frozen_string_literal: true

class Product
  attr_accessor :id, :brand, :brandtier, :category, :base_price, :current_price

  def initialize(id:, brand:, brandtier:, category:, base_price:, current_price: nil)
    raise ArgumentError, "id must be present" if id.nil?
    raise ArgumentError, "brand tier is invalid" unless BrandTier.all.include?(brandtier)
    raise ArgumentError, "base_price must be numeric" unless base_price.is_a?(Numeric)

    @id = id
    @brand = brand
    @brandtier = brandtier
    @category = category
    @base_price = base_price

    # If current_price not provided, default to base_price
    @current_price = current_price || base_price
  end

  # Helper method to check if product belongs to a specific brand tier
  def tier?(tier_value)
    brandtier == tier_value
  end

  # Pretty-prints product details in a readable format
  def product_details
    <<~DETAILS
      1. Product id: #{id}
      2. brand: #{brand}
      3. brandtier: #{brandtier}
      4. category: #{category}
      5. base price: #{base_price}
      6. current price: #{current_price}
    DETAILS
  end
end 
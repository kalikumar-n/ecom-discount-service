# frozen_string_literal: true

class Product
  attr_accessor :id, :brand, :brandtier, :category, :base_price, :current_price

  def initialize(id:, brand:, brandtier:, category:, base_price:, current_price: nil)
    @id = id
    @brand = brand
    @brandtier = brandtier
    @category = category
    @base_price = base_price
    @current_price = current_price || base_price
  end

  def premium_brand?
    brandtier == BrandTier::PREMIUM
  end

  def regular_brand?
    brandtier == BrandTier::REGULAR
  end

  def budget_brand?
    brandtier == BrandTier::BUDGET
  end
end 
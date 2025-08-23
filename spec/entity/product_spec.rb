# frozen_string_literal: true

require 'spec_helper'
require_relative '../../lib/entity/product'
require_relative '../../lib/enum/brand_tier'

RSpec.describe Product do
  describe '#initialize' do
    it 'creates a product with required attributes' do
      product = Product.new(
        id: 1,
        brand: 'Apple',
        brandtier: BrandTier::PREMIUM,
        category: 'electronics',
        base_price: 999.99
      )

      expect(product.id).to eq(1)
      expect(product.brand).to eq('Apple')
      expect(product.brandtier).to eq(BrandTier::PREMIUM)
      expect(product.category).to eq('electronics')
      expect(product.base_price).to eq(999.99)
      expect(product.current_price).to eq(999.99)
    end

    it 'creates a product with custom current price' do
      product = Product.new(
        id: 2,
        brand: 'Samsung',
        brandtier: BrandTier::REGULAR,
        category: 'electronics',
        base_price: 799.99,
        current_price: 699.99
      )

      expect(product.current_price).to eq(699.99)
    end

    it 'sets current_price to base_price when not provided' do
      product = Product.new(
        id: 3,
        brand: 'Generic',
        brandtier: BrandTier::BUDGET,
        category: 'clothing',
        base_price: 29.99
      )

      expect(product.current_price).to eq(29.99)
    end
  end

  describe '#premium_brand?' do
    it 'returns true for premium brand tier' do
      product = Product.new(
        id: 1,
        brand: 'Apple',
        brandtier: BrandTier::PREMIUM,
        category: 'electronics',
        base_price: 999.99
      )

      expect(product.premium_brand?).to be true
    end

    it 'returns false for non-premium brand tier' do
      product = Product.new(
        id: 2,
        brand: 'Samsung',
        brandtier: BrandTier::REGULAR,
        category: 'electronics',
        base_price: 799.99
      )

      expect(product.premium_brand?).to be false
    end
  end

  describe '#regular_brand?' do
    it 'returns true for regular brand tier' do
      product = Product.new(
        id: 1,
        brand: 'Samsung',
        brandtier: BrandTier::REGULAR,
        category: 'electronics',
        base_price: 799.99
      )

      expect(product.regular_brand?).to be true
    end

    it 'returns false for non-regular brand tier' do
      product = Product.new(
        id: 2,
        brand: 'Apple',
        brandtier: BrandTier::PREMIUM,
        category: 'electronics',
        base_price: 999.99
      )

      expect(product.regular_brand?).to be false
    end
  end

  describe '#budget_brand?' do
    it 'returns true for budget brand tier' do
      product = Product.new(
        id: 1,
        brand: 'Generic',
        brandtier: BrandTier::BUDGET,
        category: 'clothing',
        base_price: 29.99
      )

      expect(product.budget_brand?).to be true
    end

    it 'returns false for non-budget brand tier' do
      product = Product.new(
        id: 2,
        brand: 'Apple',
        brandtier: BrandTier::PREMIUM,
        category: 'electronics',
        base_price: 999.99
      )

      expect(product.budget_brand?).to be false
    end
  end
end 
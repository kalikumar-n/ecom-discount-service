# frozen_string_literal: true

require 'spec_helper'
require_relative '../../lib/strategies/brand_discount'
require_relative '../../lib/entity/cart_item'
require_relative '../../lib/entity/product'
require_relative '../../lib/enum/brand_tier'


RSpec.describe BrandDiscount do
  let(:brand_discount) { BrandDiscount.new }

  describe '#apply' do
    let(:nike_product) do
      Product.new(
        id: 1,
        brand: 'Nike',
        brandtier: BrandTier::PREMIUM,
        category: 'clothing',
        base_price: 100.0,
        current_price: 100.0
      )
    end

    let(:puma_product) do
      Product.new(
        id: 2,
        brand: 'Puma',
        brandtier: BrandTier::REGULAR,
        category: 'clothing',
        base_price: 80.0,
        current_price: 80.0
      )
    end

    let(:adidas_product) do
      Product.new(
        id: 3,
        brand: 'Adidas',
        brandtier: BrandTier::REGULAR,
        category: 'clothing',
        base_price: 90.0,
        current_price: 90.0
      )
    end

    let(:generic_product) do
      Product.new(
        id: 4,
        brand: 'Generic',
        brandtier: BrandTier::BUDGET,
        category: 'clothing',
        base_price: 50.0,
        current_price: 50.0
      )
    end

    it 'applies Nike brand discount correctly' do
      cart_items = [CartItem.new(product: nike_product, quantity: 1)]
      current_price = 100.0

      result = brand_discount.apply(
        cart_items: cart_items,
        current_price: current_price
      )

      expect(result[:final_price]).to eq(75.0)  # 100 - (100 * 0.25)
      expect(result[:applied_discounts]['Brand Discount']).to eq(25.0)
    end

    it 'applies Puma brand discount correctly' do
      cart_items = [CartItem.new(product: puma_product, quantity: 1)]
      current_price = 80.0

      result = brand_discount.apply(
        cart_items: cart_items,
        current_price: current_price
      )

      expect(result[:final_price]).to eq(48.0)  # 80 - (80 * 0.40)
      expect(result[:applied_discounts]['Brand Discount']).to eq(32.0)
    end

    it 'applies Adidas brand discount correctly' do
      cart_items = [CartItem.new(product: adidas_product, quantity: 1)]
      current_price = 90.0

      result = brand_discount.apply(
        cart_items: cart_items,
        current_price: current_price
      )

      expect(result[:final_price]).to eq(76.5)  # 90 - (90 * 0.15)
      expect(result[:applied_discounts]['Brand Discount']).to eq(13.5)
    end

    it 'applies no discount for unknown brands' do
      cart_items = [CartItem.new(product: generic_product, quantity: 1)]
      current_price = 50.0

      result = brand_discount.apply(
        cart_items: cart_items,
        current_price: current_price
      )

      expect(result[:final_price]).to eq(50.0)
      expect(result[:applied_discounts]['Brand Discount']).to eq(0.0)
    end

    it 'handles multiple items with different brands' do
      cart_items = [
        CartItem.new(product: nike_product, quantity: 1),
        CartItem.new(product: puma_product, quantity: 1),
        CartItem.new(product: generic_product, quantity: 1)
      ]
      current_price = 230.0

      result = brand_discount.apply(
        cart_items: cart_items,
        current_price: current_price
      )

      # Nike: 100 * 0.25 = 25, Puma: 80 * 0.40 = 32, Generic: 50 * 0 = 0
      total_discount = 25.0 + 32.0 + 0.0
      expect(result[:final_price]).to eq(230.0 - total_discount)
      expect(result[:applied_discounts]['Brand Discount']).to eq(total_discount)
    end

    it 'handles case insensitive brand matching' do
      nike_lowercase = Product.new(
        id: 5,
        brand: 'nike',
        brandtier: BrandTier::PREMIUM,
        category: 'clothing',
        base_price: 100.0,
        current_price: 100.0
      )

      cart_items = [CartItem.new(product: nike_lowercase, quantity: 1)]
      current_price = 100.0

      result = brand_discount.apply(
        cart_items: cart_items,
        current_price: current_price
      )

      expect(result[:final_price]).to eq(75.0)
      expect(result[:applied_discounts]['Brand Discount']).to eq(25.0)
    end

    it 'handles zero quantity items' do
      cart_items = [CartItem.new(product: nike_product, quantity: 0)]
      current_price = 0.0

      result = brand_discount.apply(
        cart_items: cart_items,
        current_price: current_price
      )

      expect(result[:final_price]).to eq(0.0)
      expect(result[:applied_discounts]['Brand Discount']).to eq(0.0)
    end
  end
end 
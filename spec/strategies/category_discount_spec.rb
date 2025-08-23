# frozen_string_literal: true

require 'spec_helper'
require_relative '../../lib/ecom_discount_services'

RSpec.describe CategoryDiscount do
  let(:category_discount) { CategoryDiscount.new }

  describe '#apply' do
    let(:electronics_product) do
      Product.new(
        id: 1,
        brand: 'Samsung',
        brandtier: BrandTier::REGULAR,
        category: 'electronics',
        base_price: 200.0,
        current_price: 200.0
      )
    end

    let(:clothing_product) do
      Product.new(
        id: 2,
        brand: 'Nike',
        brandtier: BrandTier::PREMIUM,
        category: 'clothing',
        base_price: 100.0,
        current_price: 100.0
      )
    end

    let(:books_product) do
      Product.new(
        id: 3,
        brand: 'Generic Books',
        brandtier: BrandTier::BUDGET,
        category: 'books',
        base_price: 50.0,
        current_price: 50.0
      )
    end

    let(:home_product) do
      Product.new(
        id: 4,
        brand: 'Generic Home',
        brandtier: BrandTier::BUDGET,
        category: 'home',
        base_price: 80.0,
        current_price: 80.0
      )
    end

    let(:unknown_category_product) do
      Product.new(
        id: 5,
        brand: 'Generic',
        brandtier: BrandTier::BUDGET,
        category: 'unknown',
        base_price: 30.0,
        current_price: 30.0
      )
    end

    it 'applies electronics category discount correctly' do
      cart_items = [CartItem.new(product: electronics_product, quantity: 1)]
      current_price = 200.0

      result = category_discount.apply(
        cart_items: cart_items,
        current_price: current_price
      )

      expect(result[:final_price]).to eq(170.0)  # 200 - (200 * 0.15)
      expect(result[:applied_discounts]['Category Discount']).to eq(30.0)
    end

    it 'applies clothing category discount correctly' do
      cart_items = [CartItem.new(product: clothing_product, quantity: 1)]
      current_price = 100.0

      result = category_discount.apply(
        cart_items: cart_items,
        current_price: current_price
      )

      expect(result[:final_price]).to eq(90.0)  # 100 - (100 * 0.10)
      expect(result[:applied_discounts]['Category Discount']).to eq(10.0)
    end

    it 'applies books category discount correctly' do
      cart_items = [CartItem.new(product: books_product, quantity: 1)]
      current_price = 50.0

      result = category_discount.apply(
        cart_items: cart_items,
        current_price: current_price
      )

      expect(result[:final_price]).to eq(46.0)  # 50 - (50 * 0.08)
      expect(result[:applied_discounts]['Category Discount']).to eq(4.0)
    end

    it 'applies home category discount correctly' do
      cart_items = [CartItem.new(product: home_product, quantity: 1)]
      current_price = 80.0

      result = category_discount.apply(
        cart_items: cart_items,
        current_price: current_price
      )

      expect(result[:final_price]).to eq(76.0)  # 80 - (80 * 0.05)
      expect(result[:applied_discounts]['Category Discount']).to eq(4.0)
    end

    it 'applies no discount for unknown categories' do
      cart_items = [CartItem.new(product: unknown_category_product, quantity: 1)]
      current_price = 30.0

      result = category_discount.apply(
        cart_items: cart_items,
        current_price: current_price
      )

      expect(result[:final_price]).to eq(30.0)
      expect(result[:applied_discounts]['Category Discount']).to eq(0.0)
    end

    it 'handles multiple items with different categories' do
      cart_items = [
        CartItem.new(product: electronics_product, quantity: 1),
        CartItem.new(product: clothing_product, quantity: 1),
        CartItem.new(product: books_product, quantity: 1),
        CartItem.new(product: unknown_category_product, quantity: 1)
      ]
      current_price = 380.0

      result = category_discount.apply(
        cart_items: cart_items,
        current_price: current_price
      )

      # Electronics: 200 * 0.15 = 30, Clothing: 100 * 0.10 = 10, Books: 50 * 0.08 = 4, Unknown: 30 * 0 = 0
      total_discount = 30.0 + 10.0 + 4.0 + 0.0
      expect(result[:final_price]).to eq(380.0 - total_discount)
      expect(result[:applied_discounts]['Category Discount']).to eq(total_discount)
    end

    it 'handles case insensitive category matching' do
      electronics_uppercase = Product.new(
        id: 6,
        brand: 'Samsung',
        brandtier: BrandTier::REGULAR,
        category: 'ELECTRONICS',
        base_price: 200.0,
        current_price: 200.0
      )

      cart_items = [CartItem.new(product: electronics_uppercase, quantity: 1)]
      current_price = 200.0

      result = category_discount.apply(
        cart_items: cart_items,
        current_price: current_price
      )

      expect(result[:final_price]).to eq(170.0)
      expect(result[:applied_discounts]['Category Discount']).to eq(30.0)
    end

    it 'handles zero quantity items' do
      cart_items = [CartItem.new(product: electronics_product, quantity: 0)]
      current_price = 0.0

      result = category_discount.apply(
        cart_items: cart_items,
        current_price: current_price
      )

      expect(result[:final_price]).to eq(0.0)
      expect(result[:applied_discounts]['Category Discount']).to eq(0.0)
    end

    it 'handles multiple quantities of same category' do
      cart_items = [CartItem.new(product: electronics_product, quantity: 3)]
      current_price = 600.0

      result = category_discount.apply(
        cart_items: cart_items,
        current_price: current_price
      )

      expect(result[:final_price]).to eq(510.0)  # 600 - (600 * 0.15)
      expect(result[:applied_discounts]['Category Discount']).to eq(90.0)
    end
  end

  describe 'constants' do
    it 'defines category discount rates' do
      expect(CategoryDiscount::CATEGORY_DISCOUNTS).to include(
        'electronics' => 0.15,
        'clothing' => 0.10,
        'books' => 0.08,
        'home' => 0.05
      )
    end

    it 'has frozen constants' do
      expect(CategoryDiscount::CATEGORY_DISCOUNTS).to be_frozen
    end
  end
end 
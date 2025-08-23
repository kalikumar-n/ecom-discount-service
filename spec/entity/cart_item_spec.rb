# frozen_string_literal: true

require 'spec_helper'
require_relative '../../lib/ecom_discount_services'

RSpec.describe CartItem do
  let(:product) do
    Product.new(
      id: 1,
      brand: 'Apple',
      brandtier: BrandTier::PREMIUM,
      category: 'electronics',
      base_price: 999.99,
      current_price: 899.99
    )
  end

  describe '#initialize' do
    it 'creates a cart item with required attributes' do
      cart_item = CartItem.new(
        product: product,
        quantity: 2
      )

      expect(cart_item.product).to eq(product)
      expect(cart_item.quantity).to eq(2)
      expect(cart_item.size).to be_nil
    end

    it 'creates a cart item with optional size' do
      cart_item = CartItem.new(
        product: product,
        quantity: 1,
        size: 'Large'
      )

      expect(cart_item.size).to eq('Large')
    end
  end

  describe '#total_price' do
    it 'calculates total price correctly' do
      cart_item = CartItem.new(
        product: product,
        quantity: 2
      )

      expected_total = 899.99 * 2
      expect(cart_item.total_price).to eq(expected_total)
    end

    it 'returns zero for zero quantity' do
      cart_item = CartItem.new(
        product: product,
        quantity: 0
      )

      expect(cart_item.total_price).to eq(0)
    end

    it 'handles single item correctly' do
      cart_item = CartItem.new(
        product: product,
        quantity: 1
      )

      expect(cart_item.total_price).to eq(899.99)
    end
  end

  describe '#total_base_price' do
    it 'calculates total base price correctly' do
      cart_item = CartItem.new(
        product: product,
        quantity: 3
      )

      expected_total = 999.99 * 3
      expect(cart_item.total_base_price).to eq(expected_total)
    end

    it 'returns zero for zero quantity' do
      cart_item = CartItem.new(
        product: product,
        quantity: 0
      )

      expect(cart_item.total_base_price).to eq(0)
    end

    it 'handles single item correctly' do
      cart_item = CartItem.new(
        product: product,
        quantity: 1
      )

      expect(cart_item.total_base_price).to eq(999.99)
    end
  end
end 
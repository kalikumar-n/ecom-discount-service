# frozen_string_literal: true

require 'spec_helper'
require_relative '../../lib/entity/discounted_price'

RSpec.describe DiscountedPrice do
  describe '#initialize' do
    it 'creates discounted price with required attributes' do
      discounted_price = DiscountedPrice.new(
        original_price: 100.0,
        final_price: 80.0
      )

      expect(discounted_price.original_price).to eq(100.0)
      expect(discounted_price.final_price).to eq(80.0)
      expect(discounted_price.applied_discounts).to eq({})
      expect(discounted_price.message).to eq('')
    end

    it 'creates discounted price with optional attributes' do
      applied_discounts = { 'Brand Discount' => 10.0, 'Coupon Discount' => 10.0 }
      message = 'Applied brand discount: $10.0; Applied coupon discount: $10.0'

      discounted_price = DiscountedPrice.new(
        original_price: 100.0,
        final_price: 80.0,
        applied_discounts: applied_discounts,
        message: message
      )

      expect(discounted_price.applied_discounts).to eq(applied_discounts)
      expect(discounted_price.message).to eq(message)
    end
  end

  describe '#total_discount' do
    it 'calculates total discount correctly' do
      discounted_price = DiscountedPrice.new(
        original_price: 100.0,
        final_price: 80.0
      )

      expect(discounted_price.total_discount).to eq(20.0)
    end

    it 'returns zero when no discount applied' do
      discounted_price = DiscountedPrice.new(
        original_price: 100.0,
        final_price: 100.0
      )

      expect(discounted_price.total_discount).to eq(0.0)
    end

    it 'handles negative final price (should not happen in practice)' do
      discounted_price = DiscountedPrice.new(
        original_price: 100.0,
        final_price: -10.0
      )

      expect(discounted_price.total_discount).to eq(110.0)
    end
  end

  describe '#discount_percentage' do
    it 'calculates discount percentage correctly' do
      discounted_price = DiscountedPrice.new(
        original_price: 100.0,
        final_price: 80.0
      )

      expect(discounted_price.discount_percentage).to eq(20.0)
    end

    it 'returns zero when no discount applied' do
      discounted_price = DiscountedPrice.new(
        original_price: 100.0,
        final_price: 100.0
      )

      expect(discounted_price.discount_percentage).to eq(0.0)
    end

    it 'returns zero when original price is zero' do
      discounted_price = DiscountedPrice.new(
        original_price: 0.0,
        final_price: 0.0
      )

      expect(discounted_price.discount_percentage).to eq(0.0)
    end

    it 'rounds percentage to 2 decimal places' do
      discounted_price = DiscountedPrice.new(
        original_price: 100.0,
        final_price: 85.5
      )

      expect(discounted_price.discount_percentage).to eq(14.5)
    end
  end
end 
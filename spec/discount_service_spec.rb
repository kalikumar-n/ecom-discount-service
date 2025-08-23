# frozen_string_literal: true

require 'spec_helper'
require_relative '../lib/discount_service'

RSpec.describe DiscountService do
  let(:premium_product) do
    Product.new(
      id: 1,
      brand: 'Apple',
      brandtier: BrandTier::PREMIUM,
      category: 'electronics',
      base_price: 999.99,
      current_price: 999.99
    )
  end

  let(:regular_product) do
    Product.new(
      id: 2,
      brand: 'Samsung',
      brandtier: BrandTier::REGULAR,
      category: 'electronics',
      base_price: 799.99,
      current_price: 799.99
    )
  end

  let(:budget_product) do
    Product.new(
      id: 3,
      brand: 'Generic',
      brandtier: BrandTier::BUDGET,
      category: 'clothing',
      base_price: 29.99,
      current_price: 29.99
    )
  end

  let(:customer) do
    CustomerProfile.new(
      id: 'CUST001',
      tier: 'premium',
      email: 'customer@example.com'
    )
  end

  let(:payment_info) do
    PaymentInfo.new(
      method: 'credit_card',
      bank_name: 'Chase',
      card_type: 'Visa'
    )
  end

  describe '.validate_discount_code' do
    it 'returns true for valid coupon codes' do
      cart_items = [CartItem.new(product: premium_product, quantity: 1)]
      
      expect(DiscountService.validate_discount_code(code: 'SAVE10', cart_items: cart_items, customer: customer)).to be true
      expect(DiscountService.validate_discount_code(code: 'SAVE20', cart_items: cart_items, customer: customer)).to be true
      expect(DiscountService.validate_discount_code(code: 'SAVE30', cart_items: cart_items, customer: customer)).to be true
      expect(DiscountService.validate_discount_code(code: 'FLAT50', cart_items: cart_items, customer: customer)).to be true
    end

    it 'returns false for invalid coupon codes' do
      cart_items = [CartItem.new(product: premium_product, quantity: 1)]
      
      expect(DiscountService.validate_discount_code(code: 'INVALID', cart_items: cart_items, customer: customer)).to be false
      expect(DiscountService.validate_discount_code(code: 'SAVE5', cart_items: cart_items, customer: customer)).to be false
      expect(DiscountService.validate_discount_code(code: '', cart_items: cart_items, customer: customer)).to be false
    end

    it 'is case insensitive for coupon codes' do
      cart_items = [CartItem.new(product: premium_product, quantity: 1)]
      
      expect(DiscountService.validate_discount_code(code: 'save10', cart_items: cart_items, customer: customer)).to be true
      expect(DiscountService.validate_discount_code(code: 'Save20', cart_items: cart_items, customer: customer)).to be true
    end
  end

  describe '.calculate_cart_discounts' do
    context 'with no discounts' do
      it 'returns original price when no discounts apply' do
        cart_items = [CartItem.new(product: budget_product, quantity: 1)]
        
        result = DiscountService.calculate_cart_discounts(
          cart_items: cart_items,
          customer: customer
        )

        expect(result.original_price).to eq(29.99)
        expect(result.final_price).to eq(29.99)
        expect(result.total_discount).to eq(0.0)
        expect(result.applied_discounts).to be_empty
      end
    end

    context 'with brand discounts only' do
      it 'applies brand tier discounts correctly' do
        cart_items = [
          CartItem.new(product: premium_product, quantity: 1),   # 15% discount
          CartItem.new(product: regular_product, quantity: 1),   # 10% discount
          CartItem.new(product: budget_product, quantity: 1)     # 5% discount
        ]

        result = DiscountService.calculate_cart_discounts(
          cart_items: cart_items,
          customer: customer
        )

        expected_original = 999.99 + 799.99 + 29.99
        expected_brand_discount = (999.99 * 0.15) + (799.99 * 0.10) + (29.99 * 0.05)
        expected_final = expected_original - expected_brand_discount

        expect(result.original_price).to eq(expected_original)
        expect(result.final_price).to be_within(0.01).of(expected_final)
        expect(result.applied_discounts['Brand Discount']).to be_within(0.01).of(expected_brand_discount)
      end
    end

    context 'with category discounts' do
      it 'applies category discounts correctly' do
        cart_items = [
          CartItem.new(product: premium_product, quantity: 1),   # electronics: 12%
          CartItem.new(product: regular_product, quantity: 1),   # electronics: 12%
          CartItem.new(product: budget_product, quantity: 1)     # clothing: 8%
        ]

        result = DiscountService.calculate_cart_discounts(
          cart_items: cart_items,
          customer: customer
        )

        # Brand discounts first
        brand_discount = (999.99 * 0.15) + (799.99 * 0.10) + (29.99 * 0.05)
        price_after_brand = (999.99 + 799.99 + 29.99) - brand_discount
        
        # Category discounts on remaining price
        category_discount = (999.99 * 0.12) + (799.99 * 0.12) + (29.99 * 0.08)
        
        expect(result.applied_discounts['Brand Discount']).to be_within(0.01).of(brand_discount)
        expect(result.applied_discounts['Category Discount']).to be_within(0.01).of(category_discount)
      end
    end

    context 'with coupon discounts' do
      it 'applies percentage coupon discount correctly' do
        cart_items = [CartItem.new(product: premium_product, quantity: 1)]
        
        result = DiscountService.calculate_cart_discounts(
          cart_items: cart_items,
          customer: customer,
          coupon_code: 'SAVE20'
        )

        original_price = 999.99
        brand_discount = original_price * 0.15
        price_after_brand = original_price - brand_discount
        coupon_discount = price_after_brand * 0.20
        final_price = price_after_brand - coupon_discount

        expect(result.final_price).to be_within(0.01).of(final_price)
        expect(result.applied_discounts['Coupon Discount']).to be_within(0.01).of(coupon_discount)
      end

      it 'applies flat amount coupon discount correctly' do
        cart_items = [CartItem.new(product: budget_product, quantity: 1)]
        
        result = DiscountService.calculate_cart_discounts(
          cart_items: cart_items,
          customer: customer,
          coupon_code: 'FLAT50'
        )

        # FLAT50 should be capped at the current price
        expect(result.applied_discounts['Coupon Discount']).to eq(29.99)
        expect(result.final_price).to eq(0.0)
      end

      it 'ignores invalid coupon codes' do
        cart_items = [CartItem.new(product: premium_product, quantity: 1)]
        
        result = DiscountService.calculate_cart_discounts(
          cart_items: cart_items,
          customer: customer,
          coupon_code: 'INVALID'
        )

        expect(result.applied_discounts).not_to have_key('Coupon Discount')
      end
    end

    context 'with bank discounts' do
      it 'applies bank discount correctly' do
        cart_items = [CartItem.new(product: premium_product, quantity: 1)]
        
        result = DiscountService.calculate_cart_discounts(
          cart_items: cart_items,
          customer: customer,
          payment_info: payment_info
        )

        # Chase bank discount: 5%
        original_price = 999.99
        brand_discount = original_price * 0.15
        price_after_brand = original_price - brand_discount
        bank_discount = price_after_brand * 0.05

        expect(result.applied_discounts['Bank Discount']).to be_within(0.01).of(bank_discount)
      end

      it 'does not apply bank discount when no bank name' do
        cart_items = [CartItem.new(product: premium_product, quantity: 1)]
        payment_without_bank = PaymentInfo.new(method: 'credit_card')
        
        result = DiscountService.calculate_cart_discounts(
          cart_items: cart_items,
          customer: customer,
          payment_info: payment_without_bank
        )

        expect(result.applied_discounts).not_to have_key('Bank Discount')
      end
    end

    context 'with all discount types' do
      it 'applies discounts in correct order: brand -> category -> coupon -> bank' do
        cart_items = [
          CartItem.new(product: premium_product, quantity: 1),
          CartItem.new(product: regular_product, quantity: 1)
        ]

        result = DiscountService.calculate_cart_discounts(
          cart_items: cart_items,
          customer: customer,
          payment_info: payment_info,
          coupon_code: 'SAVE10'
        )

        expect(result.applied_discounts.keys).to eq(['Brand Discount', 'Category Discount', 'Coupon Discount', 'Bank Discount'])
        expect(result.final_price).to be >= 0
      end
    end

    context 'error handling' do
      it 'raises DiscountCalculationException when calculation fails' do
        # Mock cart_items to cause an error
        allow_any_instance_of(Array).to receive(:sum).and_raise(StandardError.new('Calculation error'))
        
        cart_items = [CartItem.new(product: premium_product, quantity: 1)]
        
        expect {
          DiscountService.calculate_cart_discounts(
            cart_items: cart_items,
            customer: customer
          )
        }.to raise_error(DiscountCalculationException)
      end

      it 'ensures final price never goes below zero' do
        cart_items = [CartItem.new(product: budget_product, quantity: 1)]
        
        result = DiscountService.calculate_cart_discounts(
          cart_items: cart_items,
          customer: customer,
          payment_info: payment_info,
          coupon_code: 'FLAT50'
        )

        expect(result.final_price).to eq(0.0)
      end
    end

    context 'edge cases' do
      it 'handles empty cart' do
        result = DiscountService.calculate_cart_discounts(
          cart_items: [],
          customer: customer
        )

        expect(result.original_price).to eq(0.0)
        expect(result.final_price).to eq(0.0)
        expect(result.total_discount).to eq(0.0)
      end

      it 'handles zero quantity items' do
        cart_items = [CartItem.new(product: premium_product, quantity: 0)]
        
        result = DiscountService.calculate_cart_discounts(
          cart_items: cart_items,
          customer: customer
        )

        expect(result.original_price).to eq(0.0)
        expect(result.final_price).to eq(0.0)
      end

      it 'handles nil payment_info' do
        cart_items = [CartItem.new(product: premium_product, quantity: 1)]
        
        result = DiscountService.calculate_cart_discounts(
          cart_items: cart_items,
          customer: customer,
          payment_info: nil
        )

        expect(result.applied_discounts).not_to have_key('Bank Discount')
      end

      it 'handles nil coupon_code' do
        cart_items = [CartItem.new(product: premium_product, quantity: 1)]
        
        result = DiscountService.calculate_cart_discounts(
          cart_items: cart_items,
          customer: customer,
          coupon_code: nil
        )

        expect(result.applied_discounts).not_to have_key('Coupon Discount')
      end
    end
  end
end 
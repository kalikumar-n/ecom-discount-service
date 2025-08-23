# frozen_string_literal: true

require 'spec_helper'
require_relative '../../lib/discount_service'

RSpec.describe 'DiscountService Integration' do
  describe 'Complete ecommerce discount workflow' do
    let(:premium_electronics) do
      Product.new(
        id: 1,
        brand: 'Apple',
        brandtier: BrandTier::PREMIUM,
        category: 'electronics',
        base_price: 1299.99,
        current_price: 1299.99
      )
    end

    let(:regular_clothing) do
      Product.new(
        id: 2,
        brand: 'Nike',
        brandtier: BrandTier::REGULAR,
        category: 'clothing',
        base_price: 89.99,
        current_price: 89.99
      )
    end

    let(:budget_books) do
      Product.new(
        id: 3,
        brand: 'Generic Books',
        brandtier: BrandTier::BUDGET,
        category: 'books',
        base_price: 19.99,
        current_price: 19.99
      )
    end

    let(:premium_customer) do
      CustomerProfile.new(
        id: 'CUST001',
        tier: 'premium',
        email: 'premium@example.com'
      )
    end

    let(:chase_payment) do
      PaymentInfo.new(
        method: 'credit_card',
        bank_name: 'Chase',
        card_type: 'Visa'
      )
    end

    it 'calculates complex cart with all discount types' do
      cart_items = [
        CartItem.new(product: premium_electronics, quantity: 1),  # $1299.99
        CartItem.new(product: regular_clothing, quantity: 2),     # $179.98
        CartItem.new(product: budget_books, quantity: 3)          # $59.97
      ]

      result = DiscountService.calculate_cart_discounts(
        cart_items: cart_items,
        customer: premium_customer,
        payment_info: chase_payment,
        coupon_code: 'SAVE20'
      )

      # Verify calculations
      expect(result.original_price).to eq(1539.94)
      expect(result.final_price).to be > 0
      expect(result.final_price).to be < result.original_price
      expect(result.applied_discounts.keys).to include('Brand Discount', 'Category Discount', 'Coupon Discount', 'Bank Discount')
      
      # Verify discount order and amounts
      brand_discount = result.applied_discounts['Brand Discount']
      category_discount = result.applied_discounts['Category Discount']
      coupon_discount = result.applied_discounts['Coupon Discount']
      bank_discount = result.applied_discounts['Bank Discount']

      expect(brand_discount).to be > 0
      expect(category_discount).to be > 0
      expect(coupon_discount).to be > 0
      expect(bank_discount).to be > 0
    end

    it 'handles large order with maximum discounts' do
      cart_items = [
        CartItem.new(product: premium_electronics, quantity: 5),  # $6499.95
        CartItem.new(product: regular_clothing, quantity: 10),    # $899.90
        CartItem.new(product: budget_books, quantity: 20)         # $399.80
      ]

      result = DiscountService.calculate_cart_discounts(
        cart_items: cart_items,
        customer: premium_customer,
        payment_info: chase_payment,
        coupon_code: 'SAVE30'
      )

      expect(result.original_price).to eq(7799.65)
      expect(result.final_price).to be > 0
      expect(result.discount_percentage).to be > 30
    end

    it 'handles edge case with FLAT50 on small order' do
      cart_items = [CartItem.new(product: budget_books, quantity: 1)]  # $19.99

      result = DiscountService.calculate_cart_discounts(
        cart_items: cart_items,
        customer: premium_customer,
        payment_info: chase_payment,
        coupon_code: 'FLAT50'
      )

      # FLAT50 should be capped at the item price
      expect(result.applied_discounts['Coupon Discount']).to eq(19.99)
      expect(result.final_price).to eq(0.0)
    end

    it 'validates multiple coupon codes in sequence' do
      cart_items = [CartItem.new(product: premium_electronics, quantity: 1)]

      # Test all valid codes
      expect(DiscountService.validate_discount_code(code: 'SAVE10', cart_items: cart_items, customer: premium_customer)).to be true
      expect(DiscountService.validate_discount_code(code: 'SAVE20', cart_items: cart_items, customer: premium_customer)).to be true
      expect(DiscountService.validate_discount_code(code: 'SAVE30', cart_items: cart_items, customer: premium_customer)).to be true
      expect(DiscountService.validate_discount_code(code: 'FLAT50', cart_items: cart_items, customer: premium_customer)).to be true

      # Test invalid codes
      expect(DiscountService.validate_discount_code(code: 'INVALID', cart_items: cart_items, customer: premium_customer)).to be false
      expect(DiscountService.validate_discount_code(code: '', cart_items: cart_items, customer: premium_customer)).to be false
    end

    it 'handles different customer tiers' do
      regular_customer = CustomerProfile.new(
        id: 'CUST002',
        tier: 'regular',
        email: 'regular@example.com'
      )

      budget_customer = CustomerProfile.new(
        id: 'CUST003',
        tier: 'budget',
        email: 'budget@example.com'
      )

      cart_items = [CartItem.new(product: premium_electronics, quantity: 1)]

      # All customers should get the same brand discount (based on product, not customer tier)
      result1 = DiscountService.calculate_cart_discounts(cart_items: cart_items, customer: premium_customer)
      result2 = DiscountService.calculate_cart_discounts(cart_items: cart_items, customer: regular_customer)
      result3 = DiscountService.calculate_cart_discounts(cart_items: cart_items, customer: budget_customer)

      expect(result1.applied_discounts['Brand Discount']).to eq(result2.applied_discounts['Brand Discount'])
      expect(result2.applied_discounts['Brand Discount']).to eq(result3.applied_discounts['Brand Discount'])
    end

    it 'handles different payment methods' do
      cart_items = [CartItem.new(product: premium_electronics, quantity: 1)]

      # Test different banks
      chase_result = DiscountService.calculate_cart_discounts(
        cart_items: cart_items,
        customer: premium_customer,
        payment_info: PaymentInfo.new(method: 'credit_card', bank_name: 'Chase')
      )

      boa_result = DiscountService.calculate_cart_discounts(
        cart_items: cart_items,
        customer: premium_customer,
        payment_info: PaymentInfo.new(method: 'credit_card', bank_name: 'Bank of America')
      )

      wells_fargo_result = DiscountService.calculate_cart_discounts(
        cart_items: cart_items,
        customer: premium_customer,
        payment_info: PaymentInfo.new(method: 'credit_card', bank_name: 'Wells Fargo')
      )

      # Different banks should have different discount amounts
      expect(chase_result.applied_discounts['Bank Discount']).to be > boa_result.applied_discounts['Bank Discount']
      expect(wells_fargo_result.applied_discounts['Bank Discount']).to be > boa_result.applied_discounts['Bank Discount']
    end

    it 'handles empty and zero quantity scenarios' do
      # Empty cart
      empty_result = DiscountService.calculate_cart_discounts(
        cart_items: [],
        customer: premium_customer,
        payment_info: chase_payment,
        coupon_code: 'SAVE20'
      )

      expect(empty_result.original_price).to eq(0.0)
      expect(empty_result.final_price).to eq(0.0)
      expect(empty_result.applied_discounts).to be_empty

      # Zero quantity
      zero_result = DiscountService.calculate_cart_discounts(
        cart_items: [CartItem.new(product: premium_electronics, quantity: 0)],
        customer: premium_customer,
        payment_info: chase_payment,
        coupon_code: 'SAVE20'
      )

      expect(zero_result.original_price).to eq(0.0)
      expect(zero_result.final_price).to eq(0.0)
    end

    it 'maintains consistency across multiple calculations' do
      cart_items = [CartItem.new(product: premium_electronics, quantity: 1)]

      # Run the same calculation multiple times
      result1 = DiscountService.calculate_cart_discounts(
        cart_items: cart_items,
        customer: premium_customer,
        payment_info: chase_payment,
        coupon_code: 'SAVE20'
      )

      result2 = DiscountService.calculate_cart_discounts(
        cart_items: cart_items,
        customer: premium_customer,
        payment_info: chase_payment,
        coupon_code: 'SAVE20'
      )

      expect(result1.original_price).to eq(result2.original_price)
      expect(result1.final_price).to eq(result2.final_price)
      expect(result1.applied_discounts).to eq(result2.applied_discounts)
    end
  end
end 
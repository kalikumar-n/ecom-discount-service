# frozen_string_literal: true

require 'spec_helper'
require_relative '../../lib/ecom_discount_services'

RSpec.describe 'DiscountService Integration' do
  describe 'Complete ecommerce discount workflow' do
    let(:discount_service) { DiscountService.new }
    
    let(:nike_product) do
      Product.new(
        id: 1,
        brand: 'Nike',
        brandtier: BrandTier::PREMIUM,
        category: 'clothing',
        base_price: 99.99,
        current_price: 99.99
      )
    end

    let(:puma_product) do
      Product.new(
        id: 2,
        brand: 'Puma',
        brandtier: BrandTier::REGULAR,
        category: 'clothing',
        base_price: 79.99,
        current_price: 79.99
      )
    end

    let(:electronics_product) do
      Product.new(
        id: 3,
        brand: 'Samsung',
        brandtier: BrandTier::REGULAR,
        category: 'electronics',
        base_price: 299.99,
        current_price: 299.99
      )
    end

    let(:gold_customer) do
      CustomerProfile.new(
        id: 'CUST001',
        tier: CustomerTier::GOLD,
        email: 'gold@example.com'
      )
    end

    let(:silver_customer) do
      CustomerProfile.new(
        id: 'CUST002',
        tier: CustomerTier::SILVER,
        email: 'silver@example.com'
      )
    end

    let(:icici_payment) do
      PaymentInfo.new(
        method: PaymentMethod::CARD,
        bank_name: 'ICICI',
        card_type: CardType::CREDIT_CARD,
        card_brand: CardBrand::VISA
      )
    end

    it 'calculates complex cart with all discount types' do
      cart_items = [
        CartItem.new(product: puma_product, quantity: 2),      # $159.98
        CartItem.new(product: electronics_product, quantity: 1) # $299.99
      ]

      result = discount_service.calculate_cart_discounts(
        cart_items: cart_items,
        customer: gold_customer,
        payment_info: icici_payment,
        coupon_code: 'SUPER69'
      )

      # Verify calculations
      expect(result.original_price).to eq(459.97)
      expect(result.final_price).to be > 0
      expect(result.final_price).to be < result.original_price
      expect(result.applied_discounts.keys).to include('Brand Discount', 'Category Discount', 'Coupon: SUPER69', 'Bank Discount')
      
      # Verify discount order and amounts
      brand_discount = result.applied_discounts['Brand Discount']
      category_discount = result.applied_discounts['Category Discount']
      coupon_discount = result.applied_discounts['Coupon: SUPER69']
      bank_discount = result.applied_discounts['Bank Discount']

      expect(brand_discount).to be > 0
      expect(category_discount).to be > 0
      expect(coupon_discount).to be > 0
      expect(bank_discount).to be > 0
    end

    it 'handles large order with maximum discounts' do
      cart_items = [
        CartItem.new(product: nike_product, quantity: 5),      # $499.95
        CartItem.new(product: puma_product, quantity: 10),     # $799.90
        CartItem.new(product: electronics_product, quantity: 3) # $899.97
      ]

      result = discount_service.calculate_cart_discounts(
        cart_items: cart_items,
        customer: gold_customer,
        payment_info: icici_payment,
        coupon_code: 'SUPER69'
      )

      expect(result.original_price).to eq(2199.82)
      expect(result.final_price).to be > 0
      expect(result.discount_percentage).to be > 10
    end

    it 'validates coupon codes through discount calculation' do
      cart_items = [CartItem.new(product: puma_product, quantity: 1)]

      # Test valid code
      result_with_valid = discount_service.calculate_cart_discounts(
        cart_items: cart_items,
        customer: gold_customer,
        coupon_code: 'WELCOME10'
      )
      expect(result_with_valid.applied_discounts).to have_key('Coupon: WELCOME10')

      # Test invalid code
      result_with_invalid = discount_service.calculate_cart_discounts(
        cart_items: cart_items,
        customer: gold_customer,
        coupon_code: 'INVALID'
      )
      expect(result_with_invalid.applied_discounts).not_to have_key('Coupon: INVALID')
    end

    it 'handles different customer tiers' do
      bronze_customer = CustomerProfile.new(
        id: 'CUST003',
        tier: CustomerTier::BRONZE,
        email: 'bronze@example.com'
      )

      cart_items = [CartItem.new(product: nike_product, quantity: 1)]

      # All customers should get the same brand discount (based on product, not customer tier)
      result1 = discount_service.calculate_cart_discounts(cart_items: cart_items, customer: gold_customer)
      result2 = discount_service.calculate_cart_discounts(cart_items: cart_items, customer: silver_customer)
      result3 = discount_service.calculate_cart_discounts(cart_items: cart_items, customer: bronze_customer)

      expect(result1.applied_discounts['Brand Discount']).to eq(result2.applied_discounts['Brand Discount'])
      expect(result2.applied_discounts['Brand Discount']).to eq(result3.applied_discounts['Brand Discount'])
    end

    it 'handles different payment methods' do
      cart_items = [CartItem.new(product: nike_product, quantity: 1)]

      # Test different banks
      icici_result = discount_service.calculate_cart_discounts(
        cart_items: cart_items,
        customer: gold_customer,
        payment_info: PaymentInfo.new(
          method: PaymentMethod::CARD,
          bank_name: 'ICICI',
          card_type: CardType::CREDIT_CARD,
          card_brand: CardBrand::VISA
        )
      )

      axis_result = discount_service.calculate_cart_discounts(
        cart_items: cart_items,
        customer: gold_customer,
        payment_info: PaymentInfo.new(
          method: PaymentMethod::CARD,
          bank_name: 'AXIS',
          card_type: CardType::CREDIT_CARD,
          card_brand: CardBrand::MASTER
        )
      )

      hdfc_result = discount_service.calculate_cart_discounts(
        cart_items: cart_items,
        customer: gold_customer,
        payment_info: PaymentInfo.new(
          method: PaymentMethod::CARD,
          bank_name: 'HDFC',
          card_type: CardType::CREDIT_CARD,
          card_brand: CardBrand::VISA
        )
      )

      # Different banks should have different discount amounts
      expect(icici_result.applied_discounts['Bank Discount']).to be > axis_result.applied_discounts['Bank Discount']
      expect(hdfc_result.applied_discounts['Bank Discount']).to be > axis_result.applied_discounts['Bank Discount']
    end

    it 'handles empty and zero quantity scenarios' do
      # Empty cart
      empty_result = discount_service.calculate_cart_discounts(
        cart_items: [],
        customer: gold_customer,
        payment_info: icici_payment,
        coupon_code: 'SUPER69'
      )

      expect(empty_result.original_price).to eq(0.0)
      expect(empty_result.final_price).to eq(0.0)
      expect(empty_result.applied_discounts.values.sum).to eq(0.0)

      # Zero quantity
      zero_result = discount_service.calculate_cart_discounts(
        cart_items: [CartItem.new(product: nike_product, quantity: 0)],
        customer: gold_customer,
        payment_info: icici_payment,
        coupon_code: 'SUPER69'
      )

      expect(zero_result.original_price).to eq(0.0)
      expect(zero_result.final_price).to eq(0.0)
    end

    it 'maintains consistency across multiple calculations' do
      cart_items = [CartItem.new(product: nike_product, quantity: 1)]

      # Run the same calculation multiple times
      result1 = discount_service.calculate_cart_discounts(
        cart_items: cart_items,
        customer: gold_customer,
        payment_info: icici_payment,
        coupon_code: 'SUPER69'
      )

      result2 = discount_service.calculate_cart_discounts(
        cart_items: cart_items,
        customer: gold_customer,
        payment_info: icici_payment,
        coupon_code: 'SUPER69'
      )

      expect(result1.original_price).to eq(result2.original_price)
      expect(result1.final_price).to eq(result2.final_price)
      expect(result1.applied_discounts).to eq(result2.applied_discounts)
    end
  end
end 
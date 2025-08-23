# frozen_string_literal: true

require 'spec_helper'
require 'strategies/brand_discount'
require 'strategies/category_discount'
require 'strategies/coupon_discount'
require 'strategies/bank_discount'

require 'entity/cart_item'
require 'entity/product'
require 'entity/customer_profile'
require 'entity/payment_info'
require 'entity/discounted_price'

require 'enum/brand_tier'
require 'enum/customer_tier'
require 'enum/payment_method'
require 'enum/card_type'
require 'enum/card_brand'

require 'discount_service'

require 'exceptions/discount_calculation_exception'
require 'exceptions/discount_validation_exception'


RSpec.describe DiscountService do
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
      email: 'customer@example.com'
    )
  end

  let(:silver_customer) do
    CustomerProfile.new(
      id: 'CUST002',
      tier: CustomerTier::SILVER,
      email: 'customer2@example.com'
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

  describe '#calculate_cart_discounts' do
    it 'calculates discounts with brand discount strategy' do
      cart_items = [CartItem.new(product: nike_product, quantity: 1)]
      
      result = discount_service.calculate_cart_discounts(
        cart_items: cart_items,
        customer: gold_customer
      )

      expect(result.original_price).to eq(99.99)
      expect(result.final_price).to be < result.original_price
      expect(result.applied_discounts).to have_key('Brand Discount')
    end

    it 'calculates discounts with category discount strategy' do
      cart_items = [CartItem.new(product: electronics_product, quantity: 1)]
      
      result = discount_service.calculate_cart_discounts(
        cart_items: cart_items,
        customer: gold_customer
      )

      expect(result.original_price).to eq(299.99)
      expect(result.final_price).to be < result.original_price
      expect(result.applied_discounts).to have_key('Category Discount')
    end

    it 'calculates discounts with coupon discount strategy' do
      cart_items = [CartItem.new(product: puma_product, quantity: 1)]
      
      result = discount_service.calculate_cart_discounts(
        cart_items: cart_items,
        customer: gold_customer,
        coupon_code: 'WELCOME10'
      )

      expect(result.original_price).to eq(79.99)
      expect(result.final_price).to be < result.original_price
      expect(result.applied_discounts).to have_key('Coupon: WELCOME10')
    end

    it 'calculates discounts with bank discount strategy' do
      cart_items = [CartItem.new(product: nike_product, quantity: 1)]
      
      result = discount_service.calculate_cart_discounts(
        cart_items: cart_items,
        customer: gold_customer,
        payment_info: icici_payment
      )

      expect(result.original_price).to eq(99.99)
      expect(result.final_price).to be < result.original_price
      expect(result.applied_discounts).to have_key('Bank Discount')
    end
  end

  describe '#calculate_cart_discounts with all strategies' do
    it 'applies all discount strategies in sequence' do
      cart_items = [
        CartItem.new(product: puma_product, quantity: 1),
        CartItem.new(product: electronics_product, quantity: 1)
      ]

      result = discount_service.calculate_cart_discounts(
        cart_items: cart_items,
        customer: gold_customer,
        payment_info: icici_payment,
        coupon_code: 'WELCOME10'
      )

      expect(result.original_price).to eq(379.98)
      expect(result.final_price).to be < result.original_price
      expect(result.applied_discounts.keys).to include('Brand Discount', 'Category Discount', 'Coupon: WELCOME10', 'Bank Discount')
    end

    it 'handles empty cart' do
      result = discount_service.calculate_cart_discounts(
        cart_items: [],
        customer: gold_customer
      )

      expect(result.original_price).to eq(0.0)
      expect(result.final_price).to eq(0.0)
      expect(result.total_discount).to eq(0.0)
    end

    it 'handles zero quantity items' do
      cart_items = [CartItem.new(product: nike_product, quantity: 0)]
      
      result = discount_service.calculate_cart_discounts(
        cart_items: cart_items,
        customer: gold_customer
      )

      expect(result.original_price).to eq(0.0)
      expect(result.final_price).to eq(0.0)
    end

    it 'handles nil payment_info' do
      cart_items = [CartItem.new(product: nike_product, quantity: 1)]
      
      result = discount_service.calculate_cart_discounts(
        cart_items: cart_items,
        customer: gold_customer,
        payment_info: nil
      )

      expect(result.applied_discounts['Bank Discount']).to eq(0.0)
    end

    it 'handles nil coupon_code' do
      cart_items = [CartItem.new(product: nike_product, quantity: 1)]
      
      result = discount_service.calculate_cart_discounts(
        cart_items: cart_items,
        customer: gold_customer,
        coupon_code: nil
      )

      expect(result.applied_discounts).not_to have_key('Coupon: SUPER69')
    end
  end

  describe 'error handling' do
    it 'raises DiscountCalculationException when calculation fails' do
      # Mock cart_items to cause an error
      allow_any_instance_of(Array).to receive(:sum).and_raise(StandardError.new('Calculation error'))
      
      cart_items = [CartItem.new(product: nike_product, quantity: 1)]
      
      expect {
        discount_service.calculate_cart_discounts(
          cart_items: cart_items,
          customer: gold_customer
        )
      }.to raise_error(DiscountCalculationException)
    end

    it 'ensures final price never goes below zero' do
      cart_items = [CartItem.new(product: nike_product, quantity: 1)]
      
      result = discount_service.calculate_cart_discounts(
        cart_items: cart_items,
        customer: gold_customer,
        payment_info: icici_payment,
        coupon_code: 'SUPER69'
      )

      expect(result.final_price).to be >= 0
    end
  end
end 
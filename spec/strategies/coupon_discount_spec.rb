# frozen_string_literal: true

require 'spec_helper'
require_relative '../../lib/ecom_discount_services'

RSpec.describe CouponDiscount do
  let(:coupon_discount) { CouponDiscount.new }

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

    let(:electronics_product) do
      Product.new(
        id: 3,
        brand: 'Samsung',
        brandtier: BrandTier::REGULAR,
        category: 'electronics',
        base_price: 200.0,
        current_price: 200.0
      )
    end

    let(:shoes_product) do
      Product.new(
        id: 4,
        brand: 'Adidas',
        brandtier: BrandTier::REGULAR,
        category: 'shoes',
        base_price: 150.0,
        current_price: 150.0
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

    let(:bronze_customer) do
      CustomerProfile.new(
        id: 'CUST003',
        tier: CustomerTier::BRONZE,
        email: 'bronze@example.com'
      )
    end

    describe 'SUPER69 coupon' do
      it 'applies SUPER69 discount for valid customer and cart' do
        cart_items = [CartItem.new(product: puma_product, quantity: 1)]
        current_price = 80.0

        result = coupon_discount.apply(
          cart_items: cart_items,
          current_price: current_price,
          coupon_code: 'SUPER69',
          customer: gold_customer
        )

        expect(result[:final_price]).to eq(11.0)  # 80 - 69
        expect(result[:applied_discounts]['Coupon: SUPER69']).to eq(69.0)
      end

      it 'applies SUPER69 for silver customer' do
        cart_items = [CartItem.new(product: puma_product, quantity: 1)]
        current_price = 80.0

        result = coupon_discount.apply(
          cart_items: cart_items,
          current_price: current_price,
          coupon_code: 'SUPER69',
          customer: silver_customer
        )

        expect(result[:final_price]).to eq(11.0)
        expect(result[:applied_discounts]['Coupon: SUPER69']).to eq(69.0)
      end

      it 'rejects SUPER69 for bronze customer' do
        cart_items = [CartItem.new(product: puma_product, quantity: 1)]
        current_price = 80.0

        result = coupon_discount.apply(
          cart_items: cart_items,
          current_price: current_price,
          coupon_code: 'SUPER69',
          customer: bronze_customer
        )

        expect(result[:final_price]).to eq(80.0)
        expect(result[:applied_discounts]).to be_empty
      end

      it 'rejects SUPER69 for excluded brand (Nike)' do
        cart_items = [CartItem.new(product: nike_product, quantity: 1)]
        current_price = 100.0

        result = coupon_discount.apply(
          cart_items: cart_items,
          current_price: current_price,
          coupon_code: 'SUPER69',
          customer: gold_customer
        )

        expect(result[:final_price]).to eq(100.0)
        expect(result[:applied_discounts]).to be_empty
      end

      it 'accepts SUPER69 for allowed category (clothing)' do
        cart_items = [CartItem.new(product: puma_product, quantity: 1)]
        current_price = 80.0

        result = coupon_discount.apply(
          cart_items: cart_items,
          current_price: current_price,
          coupon_code: 'SUPER69',
          customer: gold_customer
        )

        expect(result[:final_price]).to eq(11.0)
        expect(result[:applied_discounts]['Coupon: SUPER69']).to eq(69.0)
      end

      it 'accepts SUPER69 for allowed category (shoes)' do
        cart_items = [CartItem.new(product: shoes_product, quantity: 1)]
        current_price = 150.0

        result = coupon_discount.apply(
          cart_items: cart_items,
          current_price: current_price,
          coupon_code: 'SUPER69',
          customer: gold_customer
        )

        expect(result[:final_price]).to eq(81.0)  # 150 - 69
        expect(result[:applied_discounts]['Coupon: SUPER69']).to eq(69.0)
      end

      it 'handles mixed cart with excluded and allowed items' do
        cart_items = [
          CartItem.new(product: nike_product, quantity: 1),      # excluded brand
          CartItem.new(product: puma_product, quantity: 1)       # allowed
        ]
        current_price = 180.0

        result = coupon_discount.apply(
          cart_items: cart_items,
          current_price: current_price,
          coupon_code: 'SUPER69',
          customer: gold_customer
        )

        # Should be rejected because Nike is excluded
        expect(result[:final_price]).to eq(180.0)
        expect(result[:applied_discounts]).to be_empty
      end
    end

    describe 'WELCOME10 coupon' do
      it 'applies WELCOME10 discount for any customer' do
        cart_items = [CartItem.new(product: nike_product, quantity: 1)]
        current_price = 100.0

        result = coupon_discount.apply(
          cart_items: cart_items,
          current_price: current_price,
          coupon_code: 'WELCOME10',
          customer: bronze_customer
        )

        expect(result[:final_price]).to eq(90.0)  # 100 - 10
        expect(result[:applied_discounts]['Coupon: WELCOME10']).to eq(10.0)
      end

      it 'applies WELCOME10 for any category' do
        cart_items = [CartItem.new(product: electronics_product, quantity: 1)]
        current_price = 200.0

        result = coupon_discount.apply(
          cart_items: cart_items,
          current_price: current_price,
          coupon_code: 'WELCOME10',
          customer: gold_customer
        )

        expect(result[:final_price]).to eq(190.0)  # 200 - 10
        expect(result[:applied_discounts]['Coupon: WELCOME10']).to eq(10.0)
      end

      it 'applies WELCOME10 for any brand' do
        cart_items = [CartItem.new(product: nike_product, quantity: 1)]
        current_price = 100.0

        result = coupon_discount.apply(
          cart_items: cart_items,
          current_price: current_price,
          coupon_code: 'WELCOME10',
          customer: gold_customer
        )

        expect(result[:final_price]).to eq(90.0)
        expect(result[:applied_discounts]['Coupon: WELCOME10']).to eq(10.0)
      end
    end

    describe 'invalid coupons' do
      it 'returns no discount for invalid coupon code' do
        cart_items = [CartItem.new(product: puma_product, quantity: 1)]
        current_price = 80.0

        result = coupon_discount.apply(
          cart_items: cart_items,
          current_price: current_price,
          coupon_code: 'INVALID',
          customer: gold_customer
        )

        expect(result[:final_price]).to eq(80.0)
        expect(result[:applied_discounts]).to be_empty
      end

      it 'returns no discount for nil coupon code' do
        cart_items = [CartItem.new(product: puma_product, quantity: 1)]
        current_price = 80.0

        result = coupon_discount.apply(
          cart_items: cart_items,
          current_price: current_price,
          coupon_code: nil,
          customer: gold_customer
        )

        expect(result[:final_price]).to eq(80.0)
        expect(result[:applied_discounts]).to be_empty
      end

      it 'returns no discount for empty coupon code' do
        cart_items = [CartItem.new(product: puma_product, quantity: 1)]
        current_price = 80.0

        result = coupon_discount.apply(
          cart_items: cart_items,
          current_price: current_price,
          coupon_code: '',
          customer: gold_customer
        )

        expect(result[:final_price]).to eq(80.0)
        expect(result[:applied_discounts]).to be_empty
      end
    end

    describe 'edge cases' do
      it 'handles discount larger than current price' do
        cart_items = [CartItem.new(product: puma_product, quantity: 1)]
        current_price = 50.0  # Less than SUPER69 discount

        result = coupon_discount.apply(
          cart_items: cart_items,
          current_price: current_price,
          coupon_code: 'SUPER69',
          customer: gold_customer
        )

        expect(result[:final_price]).to eq(0)  # 50 - 69
        expect(result[:applied_discounts]['Coupon: SUPER69']).to eq(50)
      end

      it 'handles zero current price' do
        cart_items = [CartItem.new(product: puma_product, quantity: 0)]
        current_price = 0.0

        result = coupon_discount.apply(
          cart_items: cart_items,
          current_price: current_price,
          coupon_code: 'WELCOME10',
          customer: gold_customer
        )

        expect(result[:final_price]).to eq(0)  # 0 - 10
        expect(result[:applied_discounts]['Coupon: WELCOME10']).to eq(0)
      end

      it 'handles case insensitive brand exclusion' do
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

        result = coupon_discount.apply(
          cart_items: cart_items,
          current_price: current_price,
          coupon_code: 'SUPER69',
          customer: gold_customer
        )

        # Should be rejected because 'nike' matches 'NIKE' (case insensitive)
        expect(result[:final_price]).to eq(100.0)
        expect(result[:applied_discounts]).to be_empty
      end

      it 'handles case insensitive category matching' do
        clothing_uppercase = Product.new(
          id: 6,
          brand: 'Puma',
          brandtier: BrandTier::REGULAR,
          category: 'CLOTHING',
          base_price: 80.0,
          current_price: 80.0
        )

        cart_items = [CartItem.new(product: clothing_uppercase, quantity: 1)]
        current_price = 80.0

        result = coupon_discount.apply(
          cart_items: cart_items,
          current_price: current_price,
          coupon_code: 'SUPER69',
          customer: gold_customer
        )

        expect(result[:final_price]).to eq(11.0)
        expect(result[:applied_discounts]['Coupon: SUPER69']).to eq(69.0)
      end
    end
  end

  describe 'constants' do
    it 'defines voucher configurations' do
      expect(CouponDiscount::VOUCHERS).to include('SUPER69')
      expect(CouponDiscount::VOUCHERS).to include('WELCOME10')
    end

    it 'has frozen constants' do
      expect(CouponDiscount::VOUCHERS).to be_frozen
    end

    it 'defines SUPER69 voucher correctly' do
      super69_voucher = CouponDiscount::VOUCHERS['SUPER69']
      expect(super69_voucher[:amount]).to eq(69)
      expect(super69_voucher[:excluded_brands]).to include('NIKE')
      expect(super69_voucher[:allowed_categories]).to include('clothing', 'shoes')
      expect(super69_voucher[:required_customer_tier]).to include(CustomerTier::GOLD, CustomerTier::SILVER)
    end

    it 'defines WELCOME10 voucher correctly' do
      welcome10_voucher = CouponDiscount::VOUCHERS['WELCOME10']
      expect(welcome10_voucher[:amount]).to eq(10)
      expect(welcome10_voucher[:excluded_brands]).to be_empty
      expect(welcome10_voucher[:allowed_categories]).to be_empty
      expect(welcome10_voucher[:required_customer_tier]).to be_empty
    end
  end
end 
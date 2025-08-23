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

require 'enum/brand_tier'
require 'enum/customer_tier'
require 'enum/payment_method'
require 'enum/card_type'
require 'enum/card_brand'



RSpec.describe 'Strategy Integration' do
  describe 'All strategies working together' do
    let(:brand_discount) { BrandDiscount.new }
    let(:category_discount) { CategoryDiscount.new }
    let(:coupon_discount) { CouponDiscount.new }
    let(:bank_discount) { BankDiscount.new }

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

    let(:gold_customer) do
      CustomerProfile.new(
        id: 'CUST001',
        tier: CustomerTier::GOLD,
        email: 'gold@example.com'
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

    it 'applies all strategies in sequence correctly' do
      cart_items = [
        CartItem.new(product: nike_product, quantity: 1),
        CartItem.new(product: puma_product, quantity: 1),
        CartItem.new(product: electronics_product, quantity: 1)
      ]

      # Start with original price
      current_price = 380.0  # 100 + 80 + 200

      # Step 1: Apply brand discount
      brand_result = brand_discount.apply(
        cart_items: cart_items,
        current_price: current_price
      )
      # Nike: 100 * 0.25 = 25, Puma: 80 * 0.40 = 32, Samsung: 200 * 0 = 0
      # Total brand discount: 57, New price: 323
      expect(brand_result[:final_price]).to eq(323.0)
      expect(brand_result[:applied_discounts]['Brand Discount']).to eq(57.0)

      # Step 2: Apply category discount
      category_result = category_discount.apply(
        cart_items: cart_items,
        current_price: brand_result[:final_price]
      )
      # Clothing: (100 + 80) * 0.10 = 18, Electronics: 200 * 0.15 = 30
      # Total category discount: 48, New price: 275
      expect(category_result[:final_price]).to eq(275.0)
      expect(category_result[:applied_discounts]['Category Discount']).to eq(48.0)

      # Step 3: Apply coupon discount (SUPER69 won't work due to Nike exclusion)
      coupon_result = coupon_discount.apply(
        cart_items: cart_items,
        current_price: category_result[:final_price],
        coupon_code: 'SUPER69',
        customer: gold_customer
      )
      # Should be rejected due to Nike exclusion
      expect(coupon_result[:final_price]).to eq(275.0)
      expect(coupon_result[:applied_discounts]).to be_empty

      # Step 4: Apply bank discount
      bank_result = bank_discount.apply(
        cart_items: cart_items,
        current_price: coupon_result[:final_price],
        payment_info: icici_payment
      )
      # ICICI: 275 * 0.05 = 13.75, New price: 261.25
      expect(bank_result[:final_price]).to eq(261.25)
      expect(bank_result[:applied_discounts]['Bank Discount']).to eq(13.75)
    end

    it 'applies all strategies with valid coupon' do
      cart_items = [CartItem.new(product: puma_product, quantity: 1)]
      current_price = 80.0

      # Step 1: Brand discount
      brand_result = brand_discount.apply(
        cart_items: cart_items,
        current_price: current_price
      )
      # Puma: 80 * 0.40 = 32, New price: 48
      expect(brand_result[:final_price]).to eq(48.0)

      # Step 2: Category discount
      category_result = category_discount.apply(
        cart_items: cart_items,
        current_price: brand_result[:final_price]
      )
      # Clothing: 80 * 0.10 = 8, New price: 40
      expect(category_result[:final_price]).to eq(40.0)

      # Step 3: Coupon discount (SUPER69 should work for Puma)
      coupon_result = coupon_discount.apply(
        cart_items: cart_items,
        current_price: category_result[:final_price],
        coupon_code: 'SUPER69',
        customer: gold_customer
      )
      # SUPER69: 69, but current price is only 40, so discount is 40
      expect(coupon_result[:final_price]).to eq(0.0)
      expect(coupon_result[:applied_discounts]['Coupon: SUPER69']).to eq(40.0)

      # Step 4: Bank discount
      bank_result = bank_discount.apply(
        cart_items: cart_items,
        current_price: coupon_result[:final_price],
        payment_info: icici_payment
      )
      # ICICI: 0 * 0.05 = 0, New price: 0
      expect(bank_result[:final_price]).to eq(0.0)
      expect(bank_result[:applied_discounts]['Bank Discount']).to eq(0.0)
    end

    it 'handles edge case with WELCOME10 coupon' do
      cart_items = [CartItem.new(product: nike_product, quantity: 1)]
      current_price = 100.0

      # Step 1: Brand discount
      brand_result = brand_discount.apply(
        cart_items: cart_items,
        current_price: current_price
      )
      # Nike: 100 * 0.25 = 25, New price: 75
      expect(brand_result[:final_price]).to eq(75.0)

      # Step 2: Category discount
      category_result = category_discount.apply(
        cart_items: cart_items,
        current_price: brand_result[:final_price]
      )
      # Clothing: 100 * 0.10 = 10, New price: 65
      expect(category_result[:final_price]).to eq(65.0)

      # Step 3: Coupon discount (WELCOME10 should work for any product)
      coupon_result = coupon_discount.apply(
        cart_items: cart_items,
        current_price: category_result[:final_price],
        coupon_code: 'WELCOME10',
        customer: gold_customer
      )
      # WELCOME10: 10, New price: 55
      expect(coupon_result[:final_price]).to eq(55.0)
      expect(coupon_result[:applied_discounts]['Coupon: WELCOME10']).to eq(10.0)

      # Step 4: Bank discount
      bank_result = bank_discount.apply(
        cart_items: cart_items,
        current_price: coupon_result[:final_price],
        payment_info: icici_payment
      )
      # ICICI: 55 * 0.05 = 2.75, New price: 52.25
      expect(bank_result[:final_price]).to eq(52.25)
      expect(bank_result[:applied_discounts]['Bank Discount']).to eq(2.75)
    end

    it 'handles empty cart scenario' do
      cart_items = []
      current_price = 0.0

      # All strategies should handle empty cart gracefully
      brand_result = brand_discount.apply(cart_items: cart_items, current_price: current_price)
      expect(brand_result[:final_price]).to eq(0.0)
      expect(brand_result[:applied_discounts]['Brand Discount']).to eq(0.0)

      category_result = category_discount.apply(cart_items: cart_items, current_price: current_price)
      expect(category_result[:final_price]).to eq(0.0)
      expect(category_result[:applied_discounts]['Category Discount']).to eq(0.0)

      coupon_result = coupon_discount.apply(
        cart_items: cart_items,
        current_price: current_price,
        coupon_code: 'WELCOME10',
        customer: gold_customer
      )
      expect(coupon_result[:final_price]).to eq(0)
      expect(coupon_result[:applied_discounts]['Coupon: WELCOME10']).to eq(0)

      bank_result = bank_discount.apply(
        cart_items: cart_items,
        current_price: current_price,
        payment_info: icici_payment
      )
      expect(bank_result[:final_price]).to eq(0.0)
      expect(bank_result[:applied_discounts]['Bank Discount']).to eq(0.0)
    end

    it 'maintains consistency across multiple applications' do
      cart_items = [CartItem.new(product: puma_product, quantity: 1)]
      current_price = 80.0

      # Run the same sequence twice
      result1 = apply_all_strategies(cart_items, current_price)
      result2 = apply_all_strategies(cart_items, current_price)

      expect(result1[:final_price]).to eq(result2[:final_price])
      expect(result1[:applied_discounts]).to eq(result2[:applied_discounts])
    end
  end

  private

  def apply_all_strategies(cart_items, current_price)
    # Apply all strategies in sequence
    brand_result = brand_discount.apply(cart_items: cart_items, current_price: current_price)
    category_result = category_discount.apply(cart_items: cart_items, current_price: brand_result[:final_price])
    coupon_result = coupon_discount.apply(
      cart_items: cart_items,
      current_price: category_result[:final_price],
      coupon_code: 'WELCOME10',
      customer: gold_customer
    )
    bank_result = bank_discount.apply(
      cart_items: cart_items,
      current_price: coupon_result[:final_price],
      payment_info: icici_payment
    )

    # Combine all applied discounts
    all_discounts = {}
    all_discounts.merge!(brand_result[:applied_discounts])
    all_discounts.merge!(category_result[:applied_discounts])
    all_discounts.merge!(coupon_result[:applied_discounts])
    all_discounts.merge!(bank_result[:applied_discounts])

    {
      final_price: bank_result[:final_price],
      applied_discounts: all_discounts
    }
  end
end 
# frozen_string_literal: true

# Test helpers and shared test data
module TestHelpers
  def create_premium_product
    Product.new(
      id: 1,
      brand: 'Apple',
      brandtier: BrandTier::PREMIUM,
      category: 'electronics',
      base_price: 999.99,
      current_price: 999.99
    )
  end

  def create_regular_product
    Product.new(
      id: 2,
      brand: 'Samsung',
      brandtier: BrandTier::REGULAR,
      category: 'electronics',
      base_price: 799.99,
      current_price: 799.99
    )
  end

  def create_budget_product
    Product.new(
      id: 3,
      brand: 'Generic',
      brandtier: BrandTier::BUDGET,
      category: 'clothing',
      base_price: 29.99,
      current_price: 29.99
    )
  end

  def create_premium_customer
    CustomerProfile.new(
      id: 'CUST001',
      tier: 'premium',
      email: 'premium@example.com'
    )
  end

  def create_regular_customer
    CustomerProfile.new(
      id: 'CUST002',
      tier: 'regular',
      email: 'regular@example.com'
    )
  end

  def create_budget_customer
    CustomerProfile.new(
      id: 'CUST003',
      tier: 'budget',
      email: 'budget@example.com'
    )
  end

  def create_chase_payment
    PaymentInfo.new(
      method: 'credit_card',
      bank_name: 'Chase',
      card_type: 'Visa'
    )
  end

  def create_boa_payment
    PaymentInfo.new(
      method: 'credit_card',
      bank_name: 'Bank of America',
      card_type: 'Mastercard'
    )
  end

  def create_wells_fargo_payment
    PaymentInfo.new(
      method: 'credit_card',
      bank_name: 'Wells Fargo',
      card_type: 'Visa'
    )
  end

  def create_sample_cart
    [
      CartItem.new(product: create_premium_product, quantity: 1),
      CartItem.new(product: create_regular_product, quantity: 1),
      CartItem.new(product: create_budget_product, quantity: 2)
    ]
  end

  def expect_discount_calculation_to_be_correct(original_price, final_price, expected_discount_percentage)
    actual_discount_percentage = ((original_price - final_price) / original_price * 100).round(2)
    expect(actual_discount_percentage).to be_within(0.01).of(expected_discount_percentage)
  end

  def expect_discounts_to_be_applied_in_order(result, expected_order)
    actual_order = result.applied_discounts.keys
    expect(actual_order).to eq(expected_order)
  end
end

RSpec.configure do |config|
  config.include TestHelpers
end 
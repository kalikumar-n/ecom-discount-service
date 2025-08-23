# frozen_string_literal: true

require 'spec_helper'
require_relative '../../lib/strategies/bank_discount'
require_relative '../../lib/enum/card_type'
require_relative '../../lib/enum/payment_method'
require_relative '../../lib/enum/card_brand'
require_relative '../../lib/entity/payment_info'


RSpec.describe BankDiscount do
  let(:bank_discount) { BankDiscount.new }

  describe '#apply' do
    let(:icici_payment) do
      PaymentInfo.new(
        method: PaymentMethod::CARD,
        bank_name: 'ICICI',
        card_type: CardType::CREDIT_CARD,
        card_brand: CardBrand::VISA
      )
    end

    let(:axis_payment) do
      PaymentInfo.new(
        method: PaymentMethod::CARD,
        bank_name: 'AXIS',
        card_type: CardType::CREDIT_CARD,
        card_brand: CardBrand::MASTER
      )
    end

    let(:hdfc_payment) do
      PaymentInfo.new(
        method: PaymentMethod::CARD,
        bank_name: 'HDFC',
        card_type: CardType::CREDIT_CARD,
        card_brand: CardBrand::VISA
      )
    end

    let(:unknown_bank_payment) do
      PaymentInfo.new(
        method: PaymentMethod::CARD,
        bank_name: 'UNKNOWN_BANK',
        card_type: CardType::CREDIT_CARD,
        card_brand: CardBrand::VISA
      )
    end

    let(:no_bank_payment) do
      PaymentInfo.new(
        method: PaymentMethod::CARD,
        bank_name: nil,
        card_type: CardType::CREDIT_CARD,
        card_brand: CardBrand::VISA
      )
    end

    it 'applies ICICI bank discount correctly' do
      current_price = 1000.0

      result = bank_discount.apply(
        cart_items: [],
        current_price: current_price,
        payment_info: icici_payment
      )

      expect(result[:final_price]).to eq(950.0)  # 1000 - (1000 * 0.05)
      expect(result[:applied_discounts]['Bank Discount']).to eq(50.0)
    end

    it 'applies AXIS bank discount correctly' do
      current_price = 1000.0

      result = bank_discount.apply(
        cart_items: [],
        current_price: current_price,
        payment_info: axis_payment
      )

      expect(result[:final_price]).to eq(970.0)  # 1000 - (1000 * 0.03)
      expect(result[:applied_discounts]['Bank Discount']).to eq(30.0)
    end

    it 'applies HDFC bank discount correctly' do
      current_price = 1000.0

      result = bank_discount.apply(
        cart_items: [],
        current_price: current_price,
        payment_info: hdfc_payment
      )

      expect(result[:final_price]).to eq(960.0)  # 1000 - (1000 * 0.04)
      expect(result[:applied_discounts]['Bank Discount']).to eq(40.0)
    end

    it 'applies no discount for unknown banks' do
      current_price = 1000.0

      result = bank_discount.apply(
        cart_items: [],
        current_price: current_price,
        payment_info: unknown_bank_payment
      )

      expect(result[:final_price]).to eq(1000.0)
      expect(result[:applied_discounts]['Bank Discount']).to eq(0.0)
    end

    it 'applies no discount when bank name is nil' do
      current_price = 1000.0

      result = bank_discount.apply(
        cart_items: [],
        current_price: current_price,
        payment_info: no_bank_payment
      )

      expect(result[:final_price]).to eq(1000.0)
      expect(result[:applied_discounts]['Bank Discount']).to eq(0.0)
    end

    it 'handles case insensitive bank name matching' do
      icici_lowercase = PaymentInfo.new(
        method: PaymentMethod::CARD,
        bank_name: 'icici',
        card_type: CardType::CREDIT_CARD,
        card_brand: CardBrand::VISA
      )

      current_price = 1000.0

      result = bank_discount.apply(
        cart_items: [],
        current_price: current_price,
        payment_info: icici_lowercase
      )

      expect(result[:final_price]).to eq(950.0)
      expect(result[:applied_discounts]['Bank Discount']).to eq(50.0)
    end

    it 'handles mixed case bank names' do
      axis_mixed_case = PaymentInfo.new(
        method: PaymentMethod::CARD,
        bank_name: 'AxIs',
        card_type: CardType::CREDIT_CARD,
        card_brand: CardBrand::MASTER
      )

      current_price = 1000.0

      result = bank_discount.apply(
        cart_items: [],
        current_price: current_price,
        payment_info: axis_mixed_case
      )

      expect(result[:final_price]).to eq(970.0)
      expect(result[:applied_discounts]['Bank Discount']).to eq(30.0)
    end

    it 'handles zero current price' do
      result = bank_discount.apply(
        cart_items: [],
        current_price: 0.0,
        payment_info: icici_payment
      )

      expect(result[:final_price]).to eq(0.0)
      expect(result[:applied_discounts]['Bank Discount']).to eq(0.0)
    end

    it 'handles small current price' do
      current_price = 10.0

      result = bank_discount.apply(
        cart_items: [],
        current_price: current_price,
        payment_info: icici_payment
      )

      expect(result[:final_price]).to eq(9.5)  # 10 - (10 * 0.05)
      expect(result[:applied_discounts]['Bank Discount']).to eq(0.5)
    end

    it 'handles large current price' do
      current_price = 10000.0

      result = bank_discount.apply(
        cart_items: [],
        current_price: current_price,
        payment_info: hdfc_payment
      )

      expect(result[:final_price]).to eq(9600.0)  # 10000 - (10000 * 0.04)
      expect(result[:applied_discounts]['Bank Discount']).to eq(400.0)
    end

    it 'rounds discount amount to 2 decimal places' do
      current_price = 333.33

      result = bank_discount.apply(
        cart_items: [],
        current_price: current_price,
        payment_info: icici_payment
      )

      # 333.33 * 0.05 = 16.6665, rounded to 16.67
      expect(result[:applied_discounts]['Bank Discount']).to eq(16.67)
      expect(result[:final_price]).to eq(316.66)  # 333.33 - 16.67
    end

    it 'compares different bank discount rates' do
      current_price = 1000.0

      icici_result = bank_discount.apply(
        cart_items: [],
        current_price: current_price,
        payment_info: icici_payment
      )

      axis_result = bank_discount.apply(
        cart_items: [],
        current_price: current_price,
        payment_info: axis_payment
      )

      hdfc_result = bank_discount.apply(
        cart_items: [],
        current_price: current_price,
        payment_info: hdfc_payment
      )

      # ICICI (5%) > HDFC (4%) > AXIS (3%)
      expect(icici_result[:applied_discounts]['Bank Discount']).to be > hdfc_result[:applied_discounts]['Bank Discount']
      expect(hdfc_result[:applied_discounts]['Bank Discount']).to be > axis_result[:applied_discounts]['Bank Discount']
    end
  end

  describe 'constants' do
    it 'defines bank discount rates' do
      expect(BankDiscount::BANK_DISCOUNTS).to include(
        'ICICI' => BigDecimal('0.05'),
        'AXIS' => BigDecimal('0.03'),
        'HDFC' => BigDecimal('0.04')
      )
    end

    it 'has frozen constants' do
      expect(BankDiscount::BANK_DISCOUNTS).to be_frozen
    end

    it 'uses BigDecimal for precision' do
      expect(BankDiscount::BANK_DISCOUNTS['ICICI']).to be_a(BigDecimal)
      expect(BankDiscount::BANK_DISCOUNTS['AXIS']).to be_a(BigDecimal)
      expect(BankDiscount::BANK_DISCOUNTS['HDFC']).to be_a(BigDecimal)
    end
  end

  describe 'inheritance' do
    it 'inherits from BaseDiscount' do
      expect(BankDiscount).to be < BaseDiscount
    end
  end
end 
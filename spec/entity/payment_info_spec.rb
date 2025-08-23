# frozen_string_literal: true

require 'spec_helper'
require_relative '../../lib/ecom_discount_services'

RSpec.describe PaymentInfo do
  describe '#initialize' do
    it 'creates payment info with required attributes' do
      payment_info = PaymentInfo.new(method: PaymentMethod::CARD)

      expect(payment_info.method).to eq(:card)
      expect(payment_info.bank_name).to be_nil
      expect(payment_info.card_type).to be_nil
    end

    it 'creates payment info with optional attributes' do
      payment_info = PaymentInfo.new(
        method: PaymentMethod::CARD,
        bank_name: 'ICICI',
        card_type: CardType::CREDIT_CARD,
        card_brand: CardBrand::VISA
      )

      expect(payment_info.method).to eq(:card)
      expect(payment_info.bank_name).to eq('ICICI')
      expect(payment_info.card_type).to eq(:credit_card)
      expect(payment_info.card_brand).to eq(:visa)
    end

    it 'raises error for invalid payment method' do
      expect {
        PaymentInfo.new(method: :invalid)
      }.to raise_error(ArgumentError, "Invalid payment method")
    end

    it 'raises error for invalid card type' do
      expect {
        PaymentInfo.new(
          method: PaymentMethod::CARD,
          card_type: :invalid
        )
      }.to raise_error(ArgumentError, "Invalid card type")
    end

    it 'raises error for invalid card brand' do
      expect {
        PaymentInfo.new(
          method: PaymentMethod::CARD,
          card_brand: :invalid
        )
      }.to raise_error(ArgumentError, "Invalid card brand")
    end
  end

  describe '#payment_method?' do
    it 'returns true for matching payment method' do
      payment_info = PaymentInfo.new(method: PaymentMethod::CARD)
      expect(payment_info.payment_method?(PaymentMethod::CARD)).to be true
    end

    it 'returns false for non-matching payment method' do
      payment_info = PaymentInfo.new(method: PaymentMethod::UPI)
      expect(payment_info.payment_method?(PaymentMethod::CARD)).to be false
    end
  end

  describe '#card_type?' do
    it 'returns true for matching card type' do
      payment_info = PaymentInfo.new(
        method: PaymentMethod::CARD,
        card_type: CardType::CREDIT_CARD
      )
      expect(payment_info.card_type?(CardType::CREDIT_CARD)).to be true
    end

    it 'returns false for non-matching card type' do
      payment_info = PaymentInfo.new(
        method: PaymentMethod::CARD,
        card_type: CardType::DEBIT_CARD
      )
      expect(payment_info.card_type?(CardType::CREDIT_CARD)).to be false
    end

    it 'returns false when card type is nil' do
      payment_info = PaymentInfo.new(method: PaymentMethod::CARD)
      expect(payment_info.card_type?(CardType::CREDIT_CARD)).to be false
    end
  end

  describe '#card_brand?' do
    it 'returns true for matching card brand' do
      payment_info = PaymentInfo.new(
        method: PaymentMethod::CARD,
        card_brand: CardBrand::VISA
      )
      expect(payment_info.card_brand?(CardBrand::VISA)).to be true
    end

    it 'returns false for non-matching card brand' do
      payment_info = PaymentInfo.new(
        method: PaymentMethod::CARD,
        card_brand: CardBrand::MASTER
      )
      expect(payment_info.card_brand?(CardBrand::VISA)).to be false
    end

    it 'returns false when card brand is nil' do
      payment_info = PaymentInfo.new(method: PaymentMethod::CARD)
      expect(payment_info.card_brand?(CardBrand::VISA)).to be false
    end
  end
end 
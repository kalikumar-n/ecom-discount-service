# frozen_string_literal: true

require 'spec_helper'
require_relative '../../lib/entity/payment_info'

RSpec.describe PaymentInfo do
  describe '#initialize' do
    it 'creates payment info with required attributes' do
      payment_info = PaymentInfo.new(method: 'credit_card')

      expect(payment_info.method).to eq('credit_card')
      expect(payment_info.bank_name).to be_nil
      expect(payment_info.card_type).to be_nil
    end

    it 'creates payment info with optional attributes' do
      payment_info = PaymentInfo.new(
        method: 'credit_card',
        bank_name: 'Chase',
        card_type: 'Visa'
      )

      expect(payment_info.method).to eq('credit_card')
      expect(payment_info.bank_name).to eq('Chase')
      expect(payment_info.card_type).to eq('Visa')
    end
  end

  describe '#credit_card?' do
    it 'returns true for credit card method' do
      payment_info = PaymentInfo.new(method: 'credit_card')
      expect(payment_info.credit_card?).to be true
    end

    it 'returns false for non-credit card method' do
      payment_info = PaymentInfo.new(method: 'debit_card')
      expect(payment_info.credit_card?).to be false
    end
  end

  describe '#debit_card?' do
    it 'returns true for debit card method' do
      payment_info = PaymentInfo.new(method: 'debit_card')
      expect(payment_info.debit_card?).to be true
    end

    it 'returns false for non-debit card method' do
      payment_info = PaymentInfo.new(method: 'credit_card')
      expect(payment_info.debit_card?).to be false
    end
  end

  describe '#bank_transfer?' do
    it 'returns true for bank transfer method' do
      payment_info = PaymentInfo.new(method: 'bank_transfer')
      expect(payment_info.bank_transfer?).to be true
    end

    it 'returns false for non-bank transfer method' do
      payment_info = PaymentInfo.new(method: 'credit_card')
      expect(payment_info.bank_transfer?).to be false
    end
  end
end 
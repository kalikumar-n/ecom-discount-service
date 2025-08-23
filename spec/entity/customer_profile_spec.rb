# frozen_string_literal: true

require 'spec_helper'
require_relative '../../lib/entity/customer_profile'

RSpec.describe CustomerProfile do
  describe '#initialize' do
    it 'creates a customer profile with required attributes' do
      customer = CustomerProfile.new(
        id: 'CUST001',
        tier: 'premium',
        email: 'customer@example.com'
      )

      expect(customer.id).to eq('CUST001')
      expect(customer.tier).to eq('premium')
      expect(customer.email).to eq('customer@example.com')
    end

    it 'creates a customer profile with optional attributes' do
      customer = CustomerProfile.new(
        id: 'CUST002',
        tier: 'regular',
        email: 'customer2@example.com',
        phone: '+1234567890',
        address: '123 Main St, City, State'
      )

      expect(customer.phone).to eq('+1234567890')
      expect(customer.address).to eq('123 Main St, City, State')
    end

    it 'sets optional attributes to nil when not provided' do
      customer = CustomerProfile.new(
        id: 'CUST003',
        tier: 'budget',
        email: 'customer3@example.com'
      )

      expect(customer.phone).to be_nil
      expect(customer.address).to be_nil
    end
  end

  describe '#premium?' do
    it 'returns true for premium tier' do
      customer = CustomerProfile.new(
        id: 'CUST001',
        tier: 'premium',
        email: 'customer@example.com'
      )

      expect(customer.premium?).to be true
    end

    it 'returns false for non-premium tier' do
      customer = CustomerProfile.new(
        id: 'CUST002',
        tier: 'regular',
        email: 'customer@example.com'
      )

      expect(customer.premium?).to be false
    end
  end

  describe '#regular?' do
    it 'returns true for regular tier' do
      customer = CustomerProfile.new(
        id: 'CUST001',
        tier: 'regular',
        email: 'customer@example.com'
      )

      expect(customer.regular?).to be true
    end

    it 'returns false for non-regular tier' do
      customer = CustomerProfile.new(
        id: 'CUST002',
        tier: 'premium',
        email: 'customer@example.com'
      )

      expect(customer.regular?).to be false
    end
  end

  describe '#budget?' do
    it 'returns true for budget tier' do
      customer = CustomerProfile.new(
        id: 'CUST001',
        tier: 'budget',
        email: 'customer@example.com'
      )

      expect(customer.budget?).to be true
    end

    it 'returns false for non-budget tier' do
      customer = CustomerProfile.new(
        id: 'CUST002',
        tier: 'premium',
        email: 'customer@example.com'
      )

      expect(customer.budget?).to be false
    end
  end
end 
# frozen_string_literal: true

require 'spec_helper'
require_relative '../../lib/ecom_discount_services'

RSpec.describe CustomerProfile do
  describe '#initialize' do
    it 'creates a customer profile with required attributes' do
      customer = CustomerProfile.new(
        id: 'CUST001',
        tier: CustomerTier::GOLD,
        email: 'customer@example.com'
      )

      expect(customer.id).to eq('CUST001')
      expect(customer.tier).to eq(:gold)
      expect(customer.email).to eq('customer@example.com')
    end

    it 'creates a customer profile with optional attributes' do
      customer = CustomerProfile.new(
        id: 'CUST002',
        tier: CustomerTier::SILVER,
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
        tier: CustomerTier::BRONZE,
        email: 'customer3@example.com'
      )

      expect(customer.phone).to be_nil
      expect(customer.address).to be_nil
    end
  end

  describe 'tier validation' do
    it 'accepts valid customer tiers' do
      expect {
        CustomerProfile.new(
          id: 'CUST001',
          tier: CustomerTier::GOLD,
          email: 'customer@example.com'
        )
      }.not_to raise_error

      expect {
        CustomerProfile.new(
          id: 'CUST002',
          tier: CustomerTier::SILVER,
          email: 'customer2@example.com'
        )
      }.not_to raise_error

      expect {
        CustomerProfile.new(
          id: 'CUST003',
          tier: CustomerTier::BRONZE,
          email: 'customer3@example.com'
        )
      }.not_to raise_error
    end

    it 'raises error for invalid customer tier' do
      expect {
        CustomerProfile.new(
          id: 'CUST001',
          tier: 'invalid',
          email: 'customer@example.com'
        )
      }.to raise_error(ArgumentError, /Invalid tier:/)
    end
  end
end 
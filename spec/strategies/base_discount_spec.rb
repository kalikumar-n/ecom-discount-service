# frozen_string_literal: true

require 'spec_helper'
require_relative '../../lib/ecom_discount_services'

RSpec.describe BaseDiscount do
  let(:base_discount) { BaseDiscount.new }

  describe '#apply_discount' do
    it 'raises NotImplementedError' do
      expect {
        base_discount.apply_discount(
          cart_items: [],
          current_price: 100.0
        )
      }.to raise_error(NotImplementedError, "Subclasses must implement the apply method")
    end
  end

  describe 'inheritance' do
    it 'can be inherited from' do
      expect(BaseDiscount).to be < Object
    end

    it 'is designed to be a base class' do
      expect(BaseDiscount.new).to be_a(BaseDiscount)
    end
  end
end 
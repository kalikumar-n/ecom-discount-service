# frozen_string_literal: true

require 'spec_helper'
require_relative '../../lib/exceptions/discount_calculation_exception'

RSpec.describe DiscountCalculationException do
  describe '#initialize' do
    it 'creates exception with message only' do
      exception = DiscountCalculationException.new('Calculation failed')
      
      expect(exception.message).to eq('Calculation failed')
      expect(exception.cause).to be_nil
    end

    it 'creates exception with message and cause' do
      original_error = StandardError.new('Original error')
      exception = DiscountCalculationException.new('Calculation failed', original_error)
      
      expect(exception.message).to eq('Calculation failed')
      expect(exception.cause).to eq(original_error)
    end

    it 'inherits from StandardError' do
      exception = DiscountCalculationException.new('Test error')
      expect(exception).to be_a(StandardError)
    end
  end

  describe '#cause' do
    it 'returns the cause when provided' do
      original_error = RuntimeError.new('Original error')
      exception = DiscountCalculationException.new('Wrapper error', original_error)
      
      expect(exception.cause).to eq(original_error)
    end

    it 'returns nil when no cause provided' do
      exception = DiscountCalculationException.new('Test error')
      expect(exception.cause).to be_nil
    end
  end
end 
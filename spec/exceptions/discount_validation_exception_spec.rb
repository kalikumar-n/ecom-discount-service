# frozen_string_literal: true

require 'spec_helper'
require_relative '../../lib/exceptions/discount_validation_exception'

RSpec.describe DiscountValidationException do
  describe '#initialize' do
    it 'creates exception with message only' do
      exception = DiscountValidationException.new('Validation failed')
      
      expect(exception.message).to eq('Validation failed')
      expect(exception.cause).to be_nil
    end

    it 'creates exception with message and cause' do
      original_error = StandardError.new('Original error')
      exception = DiscountValidationException.new('Validation failed', original_error)
      
      expect(exception.message).to eq('Validation failed')
      expect(exception.cause).to eq(original_error)
    end

    it 'inherits from StandardError' do
      exception = DiscountValidationException.new('Test error')
      expect(exception).to be_a(StandardError)
    end
  end

  describe '#cause' do
    it 'returns the cause when provided' do
      original_error = RuntimeError.new('Original error')
      exception = DiscountValidationException.new('Wrapper error', original_error)
      
      expect(exception.cause).to eq(original_error)
    end

    it 'returns nil when no cause provided' do
      exception = DiscountValidationException.new('Test error')
      expect(exception.cause).to be_nil
    end
  end
end 
# frozen_string_literal: true

class DiscountCalculationException < StandardError
  attr_reader :cause

  def initialize(message, cause = nil)
    super(message)
    @cause = cause
  end
end 
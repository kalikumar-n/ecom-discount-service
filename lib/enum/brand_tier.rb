# frozen_string_literal: true

module BrandTier
  PREMIUM = 'premium'
  REGULAR = 'regular'
  BUDGET = 'budget'

  def self.all
    [PREMIUM, REGULAR, BUDGET]
  end

  def self.valid?(tier)
    all.include?(tier)
  end
end 
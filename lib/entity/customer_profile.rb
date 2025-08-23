# frozen_string_literal: true

class CustomerProfile
  attr_accessor :id, :tier, :email, :phone, :address

  def initialize(id:, tier:, email:, phone: nil, address: nil)
    raise ArgumentError, "id must be provided" if id.nil?
    
    unless CustomerTier.all.include?(tier)
      raise ArgumentError, "Invalid tier: #{tier.inspect}. Must be one of: #{valid_tiers.join(', ')}"
    end

    raise ArgumentError, "email must be provided" if email.nil? || email.empty?  

    @id = id
    @tier = tier
    @email = email
    @phone = phone
    @address = address
  end

  def value?(tier_value)
    tier == tier_value
  end
  
end 
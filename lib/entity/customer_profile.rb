# frozen_string_literal: true

class CustomerProfile
  attr_accessor :id, :tier, :email, :phone, :address

  def initialize(id:, tier:, email:, phone: nil, address: nil)
    raise ArgumentError, "id must be provided" if id.nil?
    raise ArgumentError, "Invalid tier" unless CustomerTier.all.include?(tier)
    raise ArgumentError, "email must be provided" if email.nil? || email.empty?  

    @id = id
    @tier = tier
    @email = email
    @phone = phone
    @address = address
  end

  def premium_customer?
    tier == CustomerTier::PREMIUM
  end
  
  def regular_customer?
    tier == CustomerTier::REGULAR
  end
  
  def budget_customer?
    tier == CustomerTier::BUDGET
  end
  
end 
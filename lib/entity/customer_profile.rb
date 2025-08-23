# frozen_string_literal: true

class CustomerProfile
  attr_accessor :id, :tier, :email, :phone, :address

  def initialize(id:, tier:, email:, phone: nil, address: nil)
    @id = id
    @tier = tier
    @email = email
    @phone = phone
    @address = address
  end

  def premium_cutomer?
    tier == CustomerTier::PREMIUM
  end

  def regular_cutomer?
    tier == CustomerTier::REGULAR
  end

  def budget_cutomer?
    tier == CustomerTier::BUDGET
  end
end 
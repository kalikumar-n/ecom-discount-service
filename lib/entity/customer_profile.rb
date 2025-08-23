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

  def premium?
    tier == 'premium'
  end

  def regular?
    tier == 'regular'
  end

  def budget?
    tier == 'budget'
  end
end 
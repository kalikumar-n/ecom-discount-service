module PaymentMethod 
  CARD = :card
  UPI = :upi
  BANK_TRANSFER = :bank_transfer

  def self.all
    constants.map { |c| const_get(c) }
  end

  def self.valid?(method)
    all.include? method
  end
end
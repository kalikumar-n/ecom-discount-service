module CardType
  CREDIT_CARD = :credit_card
  DEBIT_CARD = :debit_card

  def self.all 
    constants.map { |c| const_get(c)}
  end

  def self.valid?(card_type)
    all.include? card_type
  end
end
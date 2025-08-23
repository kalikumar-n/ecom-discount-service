module CustomerTier
  PREMIUM = :premium
  REGULAR = :regular
  BUDGET = :budget

  def self.all
    constants.map { |c| const_get(c) }
  end

  def self.valid?(tier)
    all.include? tier
  end

end
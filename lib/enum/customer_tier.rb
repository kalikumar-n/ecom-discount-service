module CustomerTier
  GOLD = :gold
  SILVER = :silver
  BRONZE = :bronze

  def self.all
    constants.map { |c| const_get(c) }
  end

  def self.valid?(tier)
    all.include? tier
  end

end
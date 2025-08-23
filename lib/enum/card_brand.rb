module CardBrand
  VISA = :visa
  MASTER = :master
  AMEX = :amex

  def self.all
    constants.map { |c| const_get(c) }
  end

  def self.valid?(brand)
    all.include? brand
  end

end
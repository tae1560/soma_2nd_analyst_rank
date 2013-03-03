class DayCandle < ActiveRecord::Base
  attr_accessible :symbol, :trading_date, :o, :h, :l, :c, :v

  belongs_to :stock_code

  has_many :recommendations

  def self.duplicated? symbol, trading_date
    self.where(:symbol => symbol, :trading_date => trading_date).exists?
  end
end

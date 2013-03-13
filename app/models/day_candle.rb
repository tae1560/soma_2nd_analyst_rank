class DayCandle < ActiveRecord::Base
  attr_accessible :symbol, :trading_date, :open, :high, :low, :close, :volume

  belongs_to :stock_code

  has_many :recommendations

end

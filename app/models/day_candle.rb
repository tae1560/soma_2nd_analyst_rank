class DayCandle < ActiveRecord::Base
  attr_accessible :symbol, :trading_date, :open, :high, :low, :close, :volume, :mongo_id

  belongs_to :stock_code

  has_many :recommendations
end

class StockCode < ActiveRecord::Base
  attr_accessible :name, :eng_name, :symbol, :mongo_id

  has_many :day_candles
  has_many :recommendations

end

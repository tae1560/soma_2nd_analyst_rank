class StockCode < ActiveRecord::Base
  attr_accessible :institution_code, :name, :eng_name, :standard_code, :short_code, :market_type, :symbol, :crawl_date

  has_many :day_candles
  has_many :recommendations

  def self.duplicated? symbol
    StockCode.where(:symbol => symbol).exists?
  end
end

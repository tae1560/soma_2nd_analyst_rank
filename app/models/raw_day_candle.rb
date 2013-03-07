class RawDayCandle < ActiveRecord::Base
  # attr_accessible :title, :body
  attr_accessible :date, :o, :h, :l, :c, :v, :symbol

  belongs_to :day_candle

  # add_index :raw_day_candles, [:symbol, :date], :unique => true
  def self.duplicated? symbol, date
    RawDayCandle.where(:symbol => symbol, :date => date).exists?
  end

  def parse_and_save
    day_candle = self.day_candle
    unless day_candle
      day_candle = DayCandle.new
      self.day_candle = day_candle
    end

    day_candle.symbol = self.symbol
    day_candle.open = self.o
    day_candle.high = self.h
    day_candle.low = self.l
    day_candle.close = self.c
    day_candle.volume = self.v

    day_candle.trading_date = self.date.to_datetime - 9.hours

    day_candle.stock_code = StockCode.find_by_symbol(day_candle.symbol)

    unless day_candle.save
      puts "ERROR : day_candle.save is not working"
    end
  end

end


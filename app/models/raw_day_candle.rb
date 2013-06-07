class RawDayCandle
  include Mongoid::Document

  # attr_accessible :title, :body
  attr_accessible :date, :o, :h, :l, :c, :v, :symbol

  field :date, type: DateTime
  field :o, type: Integer
  field :h, type: Integer
  field :l, type: Integer
  field :c, type: Integer
  field :v, type: Integer
  field :symbol, type: String

  belongs_to :day_candle, :inverse_of => :raw_day_candles

  validates_uniqueness_of :date, :scope => :symbol
  validates_presence_of :date, :symbol

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

    day_candle.stock_code = StockCode.find_by(:symbol => day_candle.symbol)

    unless day_candle.save
      puts "ERROR : day_candle.save is not working"
      puts "#{day_candle.errors.full_messages.inspect}"
      puts self.inspect
      puts day_candle.inspect
    else
      self.save
    end
  end

end


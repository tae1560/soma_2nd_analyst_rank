class DayCandle
  include Mongoid::Document

  attr_accessible :symbol , :trading_date, :open, :high, :low, :close, :volume

  field :symbol, type: String
  field :trading_date, type: DateTime
  field :open, type: Integer
  field :high, type: Integer
  field :low, type: Integer
  field :close, type: Integer
  field :volume, type: Integer

  belongs_to :stock_code, :inverse_of => :day_candles

  has_many :recommendations
  has_many :raw_day_candles

  validates_uniqueness_of :symbol, :scope => :trading_date
  validates_presence_of :symbol, :trading_date
end

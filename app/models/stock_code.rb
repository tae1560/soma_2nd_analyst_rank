class StockCode
  include Mongoid::Document

  attr_accessible :name, :eng_name, :symbol

  field :name, type: String
  field :eng_name, type: String
  field :symbol, type: String

  has_many :day_candles
  has_many :recommendations

  validates_uniqueness_of :symbol
  validates_presence_of :symbol

end

class MongoStockCode
  include Mongoid::Document
  include Mongoid::Timestamps

  store_in collection: "stock_codes"

  field :name, type: String
  field :eng_name, type: String
  field :symbol, type: String
  
  has_many :day_candles
  has_many :recommendations

  validates_uniqueness_of :symbol
  validates_presence_of :symbol
end
class MongoStockCode
  include Mongoid::Document
  include Mongoid::Timestamps

  store_in collection: "stock_codes"

  field :name, type: String
  field :eng_name, type: String
  field :symbol, type: String
  
  has_many :day_candles, :class_name => "MongoDayCandle"
  has_many :recommendations, :class_name => "MongoRecommendation"

  validates_uniqueness_of :symbol
  validates_presence_of :symbol

  index({ symbol: 1}, { unique: true })
end
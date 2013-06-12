class MongoDayCandle
  include Mongoid::Document
  include Mongoid::Timestamps

  store_in collection: "day_candles"

  field :symbol, type: String
  field :trading_date, type: DateTime
  field :open, type: Integer
  field :high, type: Integer
  field :low, type: Integer
  field :close, type: Integer
  field :volume, type: Integer
  
  belongs_to :stock_code, :class_name => "MongoStockCode"
  has_many :recommendations, :class_name => "MongoRecommendation"

  validates_uniqueness_of :symbol, :scope => :trading_date
  validates_presence_of :symbol, :trading_date

  index({ symbol: 1, trading_date: 1}, { unique: true })
end
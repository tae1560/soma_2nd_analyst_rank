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
  
  belongs_to :stockcode
  has_many :recommendations

end
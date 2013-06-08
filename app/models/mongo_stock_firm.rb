class MongoStockFirm
  include Mongoid::Document
  include Mongoid::Timestamps

  store_in collection: "stock_firms"

  field :name, type: String
  
  has_many :analyses
  has_many :recommendations

end
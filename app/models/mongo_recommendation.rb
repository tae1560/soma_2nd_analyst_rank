class MongoRecommendation
  include Mongoid::Document
  include Mongoid::Timestamps

  store_in collection: "recommendations"

  field :in_date, type: DateTime
  field :symbol, type: String
  
  belongs_to :stockcode
  belongs_to :daycandle
  belongs_to :stockfirm

end
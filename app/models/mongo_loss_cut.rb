class MongoLossCut
  include Mongoid::Document
  include Mongoid::Timestamps

  store_in collection: "loss_cuts"

  field :percent, type: Float
  
  has_many :analyses

end
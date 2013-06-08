class MongoRecentPeriod
  include Mongoid::Document
  include Mongoid::Timestamps

  store_in collection: "recent_periods"

  field :name, type: String
  field :days, type: Integer
  
  has_many :analyses

end